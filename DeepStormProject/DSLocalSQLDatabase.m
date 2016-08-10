//
//  DSLocalSQLDatabase.m
//  ReporterProject
//
//  Created by Alexandr Babenko on 21.07.16.
//  Copyright © 2016 Alexandr Babenko. All rights reserved.
//

#import "DSLocalSQLDatabase.h"
#import "DSStreamingDatabaseEvent.h"
#import "DSStreamingComplexEvent.h"

#import "DSAdaptedDBService.h"
#import "DSAdaptedDBJournal.h"
#import "DSAdaptedDBJournalRecord.h"
#import "DSAdaptedDBError.h"

#import "DSAdaptedDBService+Convertation.h"
#import "DSAdaptedDBJournal+Convertation.h"
#import "DSAdaptedDBJournalRecord+Convertation.h"
#import "DSAdaptedDBError+Convertation.h"

#import "DSLocalSQLEntitiesProvider.h"

@import CoreData;


static NSString* const DS_LOCAL_DB_FILENAME = @"DeepStorm21.sqlite";


@interface DSLocalSQLDatabase ()

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@end


@implementation DSLocalSQLDatabase

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

+ (instancetype)sharedDeepStormLocalDatabase{
    
    static DSLocalSQLDatabase *_deepStormSharedDatabase = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _deepStormSharedDatabase = [DSLocalSQLDatabase new];
    });
    return _deepStormSharedDatabase;
}

- (instancetype)init{
    if(self = [super init]){
        [self configurationDatabase];
    }
    return self;
}

- (void)configurationDatabase{
    
    _managedObjectModel = [self createManagedObjectModel];
    _persistentStoreCoordinator = [self createStoreCoordinator];
    _managedObjectContext = [self createManagedObjectContext];
    
    _modelsFactory = [DSAdaptedObjectsFactory factoryWitnContext:_managedObjectContext];
}


#pragma mark - CREATION Core Data ENVIRONMENT

/// Метод создания CoreData модели БД, выступает так-же в качестве акцессора
- (NSManagedObjectModel *)createManagedObjectModel {
    
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    
    NSEntityDescription *serviceEntity  = [DSLocalSQLEntitiesProvider serviceEntity];
    NSEntityDescription *journalEntity = [DSLocalSQLEntitiesProvider journalEntity];
    NSEntityDescription *errorEntity = [DSLocalSQLEntitiesProvider errorEntity];
    NSEntityDescription *recordEntity = [DSLocalSQLEntitiesProvider recordEntity];
    
    [DSLocalSQLEntitiesProvider setRelationsBetweenService:serviceEntity andJournal:journalEntity];
    [DSLocalSQLEntitiesProvider setRelationsBetweenService:serviceEntity andError:errorEntity];
    [DSLocalSQLEntitiesProvider setRelationsBetweenJournal:journalEntity andRecord:recordEntity];
    
    
    NSManagedObjectModel *managedObjectModel = [NSManagedObjectModel new];
    managedObjectModel.entities = @[serviceEntity, journalEntity, errorEntity, recordEntity];
    
    return managedObjectModel;
}

/// Создание координатора хранилищ (Извлекает файл базы данных, и добавляет хранилище в координатор) (скопирован функционал из стандартного Apple CoreData каркаса)
- (NSPersistentStoreCoordinator *)createStoreCoordinator {
    
    // Инициализирует хранилище моделью
    NSPersistentStoreCoordinator *persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:_managedObjectModel];
    // Формирует путь к хранилищу
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:DS_LOCAL_DB_FILENAME];
    
    // Пытается создать хранилище, если требуется, либо загрузить
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        
        // Если возникла ошибка - прервать приложение
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return persistentStoreCoordinator;
}

/// Создание контекста для моделей из базы данных
- (NSManagedObjectContext *)createManagedObjectContext {
    
    // Если хранилище не удалось получить
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (! coordinator) {
        return nil;
    }
    
    // Устанавливает хранилище в контекст, из которого будут тягаться данные
    NSManagedObjectContext *managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [managedObjectContext setPersistentStoreCoordinator:coordinator];
    
    return managedObjectContext;
}

/// Путь к папке Documents приложения
- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}



#pragma mark - EXECUTE Events

/**
    @abstract Метод обработки транзакции
    @discussion
    Проверяет, поддерживается ли переданный тип транзакции, и роутит к обработчику соответствующего типа транзакции, которые уже выполнит обработку транзакции
 
    @note
    Поддерживается 2 типа транзакций :
    - Нативная простая транзакция для БД DSStreamingDatabaseEvent
    - Комплексная тразакция DSStreamingComplexEvent, содержащая в себе DSStreamingDatabaseEvent
 
    @param databaseEvent        Объект транзакции для базы данных
    @return YES - если транзакция обработалась успешно
 */
- (BOOL)executeStreamingEvent:(id<DSStreamingEventProtocol>)databaseEvent{
    
    //MARK: Добавить еще поддержку  инкрементивных транзакций
    
    BOOL isSimpleDatabaseEvent = [databaseEvent isKindOfClass:[DSStreamingDatabaseEvent class]];
    BOOL isComplexDatabaseEvent = [databaseEvent isKindOfClass:[DSStreamingComplexEvent class]];
    if(isSimpleDatabaseEvent){
        
        // Нужно обработать простое событие
        DSStreamingDatabaseEvent *dbSimpleEvent = (DSStreamingDatabaseEvent*)databaseEvent;
        id<DSEventConvertibleEntity> convertibleEntity = dbSimpleEvent.streamingEntity;
        BOOL isSuccessUpdated = [self updateDBWithEntity:convertibleEntity withPostSynchronization:YES];
        return isSuccessUpdated;
        
    }else if(isComplexDatabaseEvent){
        
        // Обработка комплексного события
        DSStreamingComplexEvent *dbComplexEvent = (DSStreamingComplexEvent*)databaseEvent;
        BOOL isSuccessExecuted = [self executeComplexSendingEvent:dbComplexEvent];
        return isSuccessExecuted;
    }else{
        
        // Этот тип события не поддерживается
        NSAssert(NO, @"This type of Sending Event (%@) don't Supported for DeepStorm Local SQLite database. %s in %@", NSStringFromClass([databaseEvent class]), __PRETTY_FUNCTION__, NSStringFromClass([self class]));
        return NO;
    }
}

/**
    @abstract Исполняется простая транзакция в БД
    @discussion
    Сущность из транзакции сразу пропихивается на контекст, и там же сохраняется. Предварительно удаляется схожая сущность, если имелась.
    @param simpleEvent       Транзакция для исполнения
    @return YES - если транзакция успешно выполнилась, и БД обновилась
 */
- (BOOL)executeSimpleEvent:(DSStreamingDatabaseEvent*)simpleEvent{
    
    id<DSEventConvertibleEntity> convertibleEntity = simpleEvent.streamingEntity;
    BOOL isSuccessTransaction = [self updateDBWithEntity:convertibleEntity withPostSynchronization:YES];
    
    return isSuccessTransaction;
}

/**
    @abstract Исполняется комплексная транзакция в БД
    @discussion
    Комплексная транзакция разбирается на вложенные, и сущность каждой транзакции помещается на контекст.
    После успешного рзмещения на контексте всех сущностей - выполняется синхронизация с БД
    @param complexEvent       Транзакция для исполнения
    @return YES - если транзакция успешно выполнилась, и БД обновилась
 */
- (BOOL)executeComplexSendingEvent:(DSStreamingComplexEvent*)complexEvent{
    
    // Обрабатывает только вложенные события отправки БД
    NSUInteger countUpdatedEntities = 0;
    for (id <DSStreamingEventProtocol> attachmentEvent in complexEvent.unionStreamingEvents) {
        
        BOOL isDBAttachmentEvent = [attachmentEvent isKindOfClass:[DSStreamingDatabaseEvent class]];
        if(isDBAttachmentEvent){
            
            DSStreamingDatabaseEvent *attachmentDBEvent = (DSStreamingDatabaseEvent*)attachmentEvent;
            id<DSEventConvertibleEntity> convertibleEntity = attachmentDBEvent.streamingEntity;
            
            // Добавляет сущность из вложенной транзакции на контекст
            BOOL isSuccessUpdated = [self updateDBWithEntity:convertibleEntity withPostSynchronization:NO];
            if(isSuccessUpdated){
                countUpdatedEntities ++;
            }
        }
    }
    
    // Если на контекст была добавлена хотя-бы одна сущность
    if(countUpdatedEntities > 0){
        
        BOOL isDBSuccessSynchronized = [self synchronizeDatabase];
        return isDBSuccessSynchronized;
    }else{
        return NO;
    }
}


#pragma mark - LowLevel working with Context (Update & Sync)

/**
    @abstract Метод помещения сущности на контекст с последующей синхронизацией
    @discussion
    Сначала ищет схожую сущность, удаляет старую (причем вложенные сущности типа записей и ошибок - удаляются автоматически).
    После - помещает новую сущность.
    Так что, фактически, выполняется полная замена сущностей
 
    После успешного рзмещения на контексте сущности - выполняется синхронизация с БД, если требуется
    @param newEntity       Сущность, которую нужно записать в БД.
    @param needSync       После окончания работы с контекстом - нужно ли синхронизировать его с хранилищем БД
    @return YES - если сущность успешно сохранена, и БД обновилась
 */
- (BOOL)updateDBWithEntity:(id<DSEventConvertibleEntity>)newEntity withPostSynchronization:(BOOL)needSync{
    
    // Удалить старое представление данного объекта (найти его в БД)
    NSManagedObject *similarManagedObject = [self findSameDatabaseObjectForEntity:newEntity];
    if(similarManagedObject){
        [self.managedObjectContext deleteObject:similarManagedObject];
    }
    
    // Создать на контексте нового представителя объекта
    NSManagedObject *newManagedObject = [self.modelsFactory adaptedModelFromEntity:newEntity];
    if(newManagedObject){
        
        if(needSync){
            BOOL isDBSuccessSynchronized = [self synchronizeDatabase];
            return isDBSuccessSynchronized;
        }else{
            return YES;
        }
    }else{
        return NO;
    }
}

/// Синхронизирует контекст с хранилищем данных
- (BOOL)synchronizeDatabase{
    
    NSError *savingError = nil;
    BOOL isContextSavingSuccess = [self.managedObjectContext save:&savingError];
    if (isContextSavingSuccess){
        
        return YES;
    }else{
        NSLog(@"Synchronization LocalDB ERROR ! %@", savingError);
        return NO;
    }
}

- (NSManagedObject*)findSameDatabaseObjectForEntity:(id<DSEventConvertibleEntity>)compareEntity{
    
    BOOL isJournalEntity = [compareEntity isKindOfClass:[DSJournal class]];
    BOOL isServiceEntity = [compareEntity isKindOfClass:[DSBaseLoggedService class]];
    if(isJournalEntity){
        
        DSJournal *compareJournal = (DSJournal*)compareEntity;
        DSAdaptedDBJournal *similarJournal = [self loadAdaptedJournalForName:compareJournal.journalName];
        return similarJournal;
        
    }else if(isServiceEntity){
        
        DSBaseLoggedService *compareService = (DSBaseLoggedService*)compareEntity;
        DSAdaptedDBService *similarService = [self loadAdaptedServiceByTypeID:compareService.serviceType orByClass:NSStringFromClass([compareService class])];
        return similarService;
        
    }else{
        return nil;
    }
}


#pragma mark - LOAD AND GET Objects

/// Получить все имеющиеся журналы в хранилище
- (NSArray<DSAdaptedDBJournal*>*)loadAdaptedAllJournals{
    
    NSEntityDescription *journalEntity = [DSLocalSQLEntitiesProvider journalEntity];
    NSArray<NSManagedObject*> *loadedEntities = [self _loadAdaptedAllObjectForEntity:journalEntity];
    return (NSArray<DSAdaptedDBJournal*>*)loadedEntities;
}

/// Получить все имеющиеся сервисы в хранилище
- (NSArray<DSAdaptedDBService*>*)loadAdaptedAllServices{
    
    NSEntityDescription *serviceEntity = [DSLocalSQLEntitiesProvider serviceEntity];
    NSArray<NSManagedObject*> *loadedEntities = [self _loadAdaptedAllObjectForEntity:serviceEntity];
    return (NSArray<DSAdaptedDBService*>*)loadedEntities;
}

/// Получить все имеющиеся записи в хранилище
- (NSArray<DSAdaptedDBJournalRecord*>*)loadAdaptedAllRecords{
    
    NSEntityDescription *recordsEntity = [DSLocalSQLEntitiesProvider recordEntity];
    NSArray<NSManagedObject*> *loadedEntities = [self _loadAdaptedAllObjectForEntity:recordsEntity];
    return (NSArray<DSAdaptedDBJournalRecord*>*)loadedEntities;
}

/**
    @abstract Найти и получить журнал по соответствующему названию
    @discussion
    Имя журнала является его уникальным идентификатором. Поиск журнала осуществляется по его имени.
    Использует фильтрацию через предикаты
 
    @param journalName       Журнал с каким названием нужно найти
    @return Возвращает представителя данного журнала на контексте
 */
- (DSAdaptedDBJournal*)loadAdaptedJournalForName:(NSString*)journalName{
    
    NSArray<DSAdaptedDBJournal*> *allJournals = [self loadAdaptedAllJournals];
    
    NSPredicate *namePredicate = [NSPredicate predicateWithFormat:@"journalName = %@", journalName];
    NSArray<DSAdaptedDBJournal*> *filteredJournals = [allJournals filteredArrayUsingPredicate:namePredicate];
    if(filteredJournals && filteredJournals.count > 0){
        return [filteredJournals firstObject];
    }else{
        return nil;
    }
}

/**
    @abstract Найти и получить сервис по соответствующим идентификаторам
    @discussion
    Для сервиса используется поиск по типу сервиса, но не каждый сервис добавлен в менеджер сервисов. Поэтому для таких сервисов выполняется поиск по названию класса
    Использует фильтрацию через предикаты
 
    @param serviceTypeID       ID сервиса в сервис-менеджере (или enum-е)
    @param serviceClass         Class сервиса, который нужно найти (конкретный подкласс)
 
    @return Возвращает представителя данного сервиса на контексте
 */
- (DSAdaptedDBService*)loadAdaptedServiceByTypeID:(NSNumber*)serviceTypeID orByClass:(NSString*)serviceClass{
    
    NSArray<DSAdaptedDBService*> *allServices = [self loadAdaptedAllServices];
    
    NSPredicate *typePredicate = [NSPredicate predicateWithFormat:@"((typeID = %@ AND typeID <> nil) OR (serviceClass = %@))", serviceTypeID, serviceClass];
    NSArray<DSAdaptedDBService*> *filteredServices = [allServices filteredArrayUsingPredicate:typePredicate];
    if(filteredServices && filteredServices.count > 0){
        return [filteredServices firstObject];
    }else{
        return nil;
    }
}


#pragma mark - PRIVATE Loading

/// Получить все имеющиеся записи в хранилище для данного типа сущности
- (NSArray<NSManagedObject*>*)_loadAdaptedAllObjectForEntity:(NSEntityDescription*)objectEntity{
    
    NSFetchRequest *executeFetchRequest = [NSFetchRequest new];
    [executeFetchRequest setEntity:objectEntity];
    
    NSError *fetchError = nil;
    NSArray <NSManagedObject*> *loadedEntities = [self.managedObjectContext executeFetchRequest:executeFetchRequest error:&fetchError];
    
    if(! loadedEntities || fetchError){
        NSLog(@"FETCH REQUEST ERROR : %@", fetchError);
    }
    
    return loadedEntities;
}

/// Получить все имеющиеся журналы в хранилище
- (NSArray<DSJournal*>*)getAllJournals{
    
    NSArray<DSAdaptedDBJournal*> *loadedEntities = [self loadAdaptedAllJournals];
    NSMutableArray<DSJournal*> *convertedEntities = [NSMutableArray new];
    
    for (DSAdaptedDBJournal *adaptedJournal in loadedEntities) {
        
        DSJournal *convertedEntity = [adaptedJournal convertToJournal];
        [convertedEntities addObject:convertedEntity];
    }
    return [NSArray arrayWithArray:convertedEntities];
}

/// Получить все имеющиеся сервисы в хранилище
- (NSArray<DSBaseLoggedService*>*)getAllServices{
    
    NSArray<DSAdaptedDBService*> *loadedEntities = [self loadAdaptedAllServices];
    NSMutableArray<DSBaseLoggedService*> *convertedEntities = [NSMutableArray new];
    
    for (DSAdaptedDBService *adaptedService in loadedEntities) {
        
        DSBaseLoggedService *convertedEntity = [adaptedService convertToService];
        [convertedEntities addObject:convertedEntity];
    }
    return [NSArray arrayWithArray:convertedEntities];
}

/// Получить все имеющиеся записи в хранилище
- (NSArray<DSJournalRecord*>*)getAllRecords{
    
    NSArray<DSAdaptedDBJournalRecord*> *loadedEntities = [self loadAdaptedAllRecords];
    NSMutableArray<DSJournalRecord*> *convertedEntities = [NSMutableArray new];
    
    for (DSAdaptedDBJournalRecord *adaptedRecord in loadedEntities) {
        
        DSJournalRecord *convertedEntity = [adaptedRecord convertToJournalRecord];
        [convertedEntities addObject:convertedEntity];
    }
    return [NSArray arrayWithArray:convertedEntities];
}

- (DSJournal*)getJournalForName:(NSString*)journalName{
    
    DSAdaptedDBJournal *adaptedJournal = [self loadAdaptedJournalForName:journalName];
    return [adaptedJournal convertToJournal];
}

- (DSBaseLoggedService*)getServiceByTypeID:(NSNumber*)serviceTypeID orByClass:(NSString*)serviceClass{
    
    DSAdaptedDBService *adaptedService = [self loadAdaptedServiceByTypeID:serviceTypeID orByClass:serviceClass];
    return [adaptedService convertToService];
}

@end
