//
//  DSLocalSQLDatabase.h
//  ReporterProject
//
//  Created by Alexandr Babenko on 21.07.16.
//  Copyright © 2016 Alexandr Babenko. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DSStreamingDatabaseEvent;
@class DSAdaptedDBService, DSAdaptedDBJournal, DSAdaptedDBError, DSAdaptedDBJournalRecord;
#import "DSAdaptedObjectsFactory.h"

@import CoreData;
@class NSManagedObjectContext;

@interface DSLocalSQLDatabase : NSObject

+ (instancetype)sharedDeepStormLocalDatabase;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (void)executeSendingEvent:(DSStreamingDatabaseEvent*)databaseEvent;


@property (strong, nonatomic, readonly) DSAdaptedObjectsFactory *modelsFactory;

- (NSArray<DSAdaptedDBJournal*>*)loadAllJournals;
- (NSArray<DSAdaptedDBService*>*)loadAllServices;
- (NSArray<DSAdaptedDBJournalRecord*>*)loadAllRecords;


@end
