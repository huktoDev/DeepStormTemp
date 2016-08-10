//
//  DSAdaptedObjectsFactory.m
//  ReporterProject
//
//  Created by Alexandr Babenko on 22.07.16.
//  Copyright © 2016 Alexandr Babenko. All rights reserved.
//

#import "DSAdaptedObjectsFactory.h"

@import CoreData;
#import "DSAdaptedDBService.h"
#import "DSAdaptedDBJournal.h"
#import "DSAdaptedDBError.h"
#import "DSAdaptedDBJournalRecord.h"
#import "DSAdaptedDBService+Convertation.h"
#import "DSAdaptedDBJournal+Convertation.h"
#import "DSAdaptedDBError+Convertation.h"
#import "DSAdaptedDBJournalRecord+Convertation.h"
#import "DSJournal.h"
#import "DSBaseLoggedService.h"

@interface DSAdaptedObjectsFactory ()

@property (strong, nonatomic, readwrite) NSManagedObjectContext *managedContext;

@end


@implementation DSAdaptedObjectsFactory

+ (instancetype)factoryWitnContext:(NSManagedObjectContext*)managedContext{
    
    DSAdaptedObjectsFactory *newFactory = [DSAdaptedObjectsFactory new];
    newFactory.managedContext = managedContext;
    return newFactory;
}

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

//TODO: Wrap Entity Keys (method entityForKey:)


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
