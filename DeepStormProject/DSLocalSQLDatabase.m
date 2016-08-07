//
//  DSLocalSQLDatabase.m
//  ReporterProject
//
//  Created by Alexandr Babenko on 21.07.16.
//  Copyright © 2016 Alexandr Babenko. All rights reserved.
//

#import "DSLocalSQLDatabase.h"
#import "DSStreamingDatabaseEvent.h"

#import "DSAdaptedDBService.h"
#import "DSAdaptedDBJournal.h"
#import "DSAdaptedDBError.h"

#import "DSLocalSQLEntitiesProvider.h"

@import CoreData;


static NSString* const DS_LOCAL_DB_FILENAME = @"DeepStorm17.sqlite";


@interface DSLocalSQLDatabase ()

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


- (void)executeSendingEvent:(DSStreamingDatabaseEvent*)databaseEvent{
    
}

//MARK: loadAllEntitiesForName:

- (NSArray<DSAdaptedDBJournal*>*)loadAllJournals{
    
    NSFetchRequest *journalsFetchRequest = [NSFetchRequest new];
    NSEntityDescription *journalEntity = [NSEntityDescription entityForName:@"Journal" inManagedObjectContext:self.managedObjectContext];
    [journalsFetchRequest setEntity:journalEntity];
    
    NSError *fetchError = nil;
    NSArray <DSAdaptedDBJournal*> *journals = [self.managedObjectContext executeFetchRequest:journalsFetchRequest error:&fetchError];
    
    if(! journals || fetchError){
        NSLog(@"FETCH REQUEST ERROR : %@", fetchError);
    }
    
    return journals;
}

- (NSArray<DSAdaptedDBService*>*)loadAllServices{
    
    NSFetchRequest *serviceFetchRequest = [NSFetchRequest new];
    NSEntityDescription *serviceEntity = [NSEntityDescription entityForName:@"Service" inManagedObjectContext:self.managedObjectContext];
    [serviceFetchRequest setEntity:serviceEntity];
    
    NSError *fetchError = nil;
    NSArray <DSAdaptedDBService*> *services = [self.managedObjectContext executeFetchRequest:serviceFetchRequest error:&fetchError];
    
    if(! services || fetchError){
        NSLog(@"FETCH REQUEST ERROR : %@", fetchError);
    }
    
    return services;
}

- (NSArray<DSAdaptedDBJournalRecord*>*)loadAllRecords{
    
    NSFetchRequest *recordsFetchRequest = [NSFetchRequest new];
    NSEntityDescription *recordsEntity = [NSEntityDescription entityForName:@"JournalRecord" inManagedObjectContext:self.managedObjectContext];
    [recordsFetchRequest setEntity:recordsEntity];
    
    NSError *fetchError = nil;
    NSArray <DSAdaptedDBJournalRecord*> *records = [self.managedObjectContext executeFetchRequest:recordsFetchRequest error:&fetchError];
    
    if(! records || fetchError){
        NSLog(@"FETCH REQUEST ERROR : %@", fetchError);
    }
    
    return records;
}



@end
