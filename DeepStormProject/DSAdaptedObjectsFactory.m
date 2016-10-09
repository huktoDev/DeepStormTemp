//
//  DSAdaptedObjectsFactory.m
//  ReporterProject
//
//  Created by Alexandr Babenko on 22.07.16.
//  Copyright © 2016 Alexandr Babenko. All rights reserved.
//

#import "DSAdaptedObjectsFactory.h"
@import CoreData;

#import "DSLocalDBModels.h"

#import "DSJournal.h"
#import "DSJournalRecord.h"
#import "DSBaseLoggedService.h"

@interface DSAdaptedObjectsFactory ()

@property (strong, nonatomic, readwrite) NSManagedObjectContext *managedContext;

@end


@implementation DSAdaptedObjectsFactory


#pragma mark - Construction

+ (instancetype)factoryWitnContext:(NSManagedObjectContext*)managedContext{
    
    DSAdaptedObjectsFactory *newFactory = [DSAdaptedObjectsFactory new];
    newFactory.managedContext = managedContext;
    return newFactory;
}


#pragma mark - MAIN Dispatch Methods

/**
    @abstract Простой метод для конвертации обычно DeepStorm модели в адаптированную
    @discussion
    Направляет в соответствующий внутренний метод.
    Поддерживает конвертацию для 4х типов сущностей :
    1) Журнал
    2) Логгируемый Сервис
    3) Запись журнала
    4) Ошибка сервиса
    @param baseEntity           Базовая конвертируемая сущность
    
 */
- (NSManagedObject*)adaptedModelFromEntity:(id<DSEventConvertibleEntity>)baseEntity{
    
    BOOL isJournalEntity = [baseEntity isKindOfClass:[DSJournal class]];
    if(isJournalEntity){
        return [self adaptedModelFromJournal:(DSJournal*)baseEntity];
    }
    
    BOOL isServiceEntity = [baseEntity isKindOfClass:[DSBaseLoggedService class]];
    if(isServiceEntity){
        return [self adaptedModelFromService:(DSBaseLoggedService*)baseEntity];
    }
    
    BOOL isRecordEntity = [baseEntity isKindOfClass:[DSJournalRecord class]];
    if(isRecordEntity){
        return [self adaptedModelFromRecord:(DSJournalRecord*)baseEntity];
    }
    
    BOOL isErrorEntity = [baseEntity isKindOfClass:[NSError class]];
    if(isErrorEntity){
        return [self adaptedModelFromError:(NSError*)baseEntity];
    }
    
    return nil;
}

- (NSManagedObject*)generateEmptyModelWithEntityKey:(DSEntityKey)entityKey{
    
    NSManagedObject *newManagedModel = nil;
    switch (entityKey) {
        case DSEntityServiceKey:
            newManagedModel = [self generateEmptyService];
            break;
        case DSEntityJournalKey:
            newManagedModel = [self generateEmptyJournal];
            break;
        case DSEntityRecordKey:
            newManagedModel = [self generateEmptyJournalRecord];
            break;
        case DSEntityErrorKey:
            newManagedModel = [self generateEmptyError];
            break;
        default:
            break;
    }
    if(! newManagedModel){
        NSAssert(NO, @"Unknown Entity Key %lu. See %s in %@", (unsigned long)entityKey, __PRETTY_FUNCTION__, NSStringFromClass([self class]));
    }
    return newManagedModel;
}



#pragma mark - CONVERTATION Methods

- (DSAdaptedDBService*)adaptedModelFromService:(DSBaseLoggedService*)baseService{
    
    DSAdaptedDBService *blankService = [self generateEmptyService];
    DSAdaptedDBService *resultService = [DSAdaptedDBService adaptedModelForService:baseService fromBlankModel:blankService andModelsFactory:self];
    
    return resultService;
}

- (DSAdaptedDBJournal*)adaptedModelFromJournal:(DSJournal*)baseJournal{
    
    DSAdaptedDBJournal *blankJournal = [self generateEmptyJournal];
    DSAdaptedDBJournal *resultJournal = [DSAdaptedDBJournal adaptedModelForJournal:baseJournal fromBlankModel:blankJournal andModelsFactory:self];
    
    return resultJournal;
}

- (DSAdaptedDBError*)adaptedModelFromError:(NSError*)baseError{
    
    DSAdaptedDBError *blankError = [self generateEmptyError];
    DSAdaptedDBError *resultError = [DSAdaptedDBError adaptedModelForError:baseError fromBlankModel:blankError];
    
    return resultError;
}

- (DSAdaptedDBJournalRecord*)adaptedModelFromRecord:(DSJournalRecord*)baseJournalRecord{
    
    DSAdaptedDBJournalRecord *blankRecord = [self generateEmptyJournalRecord];
    DSAdaptedDBJournalRecord *resultRecord = [DSAdaptedDBJournalRecord adaptedModelForRecord:baseJournalRecord fromBlankModel:blankRecord];
    
    return resultRecord;
}


#pragma mark - GENERATION BLANK Methods

- (DSAdaptedDBService*)generateEmptyService{
    
    NSEntityDescription *serviceEntity = [NSEntityDescription entityForName:@"Service" inManagedObjectContext:self.managedContext];
    DSAdaptedDBService *newService = (DSAdaptedDBService*)[NSEntityDescription insertNewObjectForEntityForName:serviceEntity.name inManagedObjectContext:self.managedContext];
    
    return newService;
}

- (DSAdaptedDBJournal*)generateEmptyJournal{
    
    NSEntityDescription *journalEntity = [NSEntityDescription entityForName:@"Journal" inManagedObjectContext:self.managedContext];
    DSAdaptedDBJournal *newJournal = (DSAdaptedDBJournal*)[NSEntityDescription insertNewObjectForEntityForName:journalEntity.name inManagedObjectContext:self.managedContext];
    
    return newJournal;
}

- (DSAdaptedDBError*)generateEmptyError{
    
    NSEntityDescription *errorEntity = [NSEntityDescription entityForName:@"Error" inManagedObjectContext:self.managedContext];
    DSAdaptedDBError *newError = (DSAdaptedDBError*)[NSEntityDescription insertNewObjectForEntityForName:errorEntity.name inManagedObjectContext:self.managedContext];
    
    return newError;
}

- (DSAdaptedDBJournalRecord*)generateEmptyJournalRecord{
    
    NSEntityDescription *journalRecordEntity = [NSEntityDescription entityForName:@"JournalRecord" inManagedObjectContext:self.managedContext];
    DSAdaptedDBJournalRecord *newRecord = (DSAdaptedDBJournalRecord*)[NSEntityDescription insertNewObjectForEntityForName:journalRecordEntity.name inManagedObjectContext:self.managedContext];
    
    return newRecord;
}

@end
