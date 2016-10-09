//
//  DSAdaptedObjectsFactory.h
//  ReporterProject
//
//  Created by Alexandr Babenko on 22.07.16.
//  Copyright © 2016 Alexandr Babenko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DSEntityKeys.h"

#import "DSSendingEventInterfaces.h"

@class NSManagedObject;
@class NSManagedObjectContext;
@class DSJournal, DSBaseLoggedService, DSJournalRecord, NSError;

@class DSAdaptedDBService;
@class DSAdaptedDBJournal;
@class DSAdaptedDBError;
@class DSAdaptedDBJournalRecord;

@interface DSAdaptedObjectsFactory : NSObject

+ (instancetype)factoryWitnContext:(NSManagedObjectContext*)managedContext;




- (DSAdaptedDBService*)adaptedModelFromService:(DSBaseLoggedService*)baseService;
- (DSAdaptedDBJournal*)adaptedModelFromJournal:(DSJournal*)baseJournal;
- (DSAdaptedDBError*)adaptedModelFromError:(NSError*)baseError;
- (DSAdaptedDBJournalRecord*)adaptedModelFromRecord:(DSJournalRecord*)baseJournalRecord;

- (NSManagedObject*)adaptedModelFromEntity:(id<DSEventConvertibleEntity>)baseEntity;

- (DSAdaptedDBService*)generateEmptyService;
- (DSAdaptedDBJournal*)generateEmptyJournal;
- (DSAdaptedDBError*)generateEmptyError;
- (DSAdaptedDBJournalRecord*)generateEmptyJournalRecord;

- (NSManagedObject*)generateEmptyModelWithEntityKey:(DSEntityKey)entityKey;

@end
