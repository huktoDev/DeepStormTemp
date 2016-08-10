//
//  DSLocalSQLDatabase.h
//  ReporterProject
//
//  Created by Alexandr Babenko on 21.07.16.
//  Copyright © 2016 Alexandr Babenko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DSStoreDataProvidingProtocol.h"

@import CoreData;
@class NSManagedObjectContext;

@protocol DSStoreDataProvidingProtocol;
@protocol DSStreamingEventExecutorProtocol;
@class DSAdaptedDBService, DSAdaptedDBJournal, DSAdaptedDBError, DSAdaptedDBJournalRecord;

#import "DSAdaptedObjectsFactory.h"

@interface DSLocalSQLDatabase : NSObject <DSStreamingEventExecutorProtocol, DSStoreDataProvidingProtocol>


#pragma mark - Construction
+ (instancetype)sharedDeepStormLocalDatabase;


#pragma mark - DSStreamingEventExecutorProtocol IMP
// Локальная БД способна обрабатывать транзакции определенного типа

- (BOOL)executeStreamingEvent:(id<DSStreamingEventProtocol>)databaseEvent;
//TODO: make Pull Request


#pragma mark - ENTITIES Factory
// Фабрика "адаптированных" объектов (представляющих реальные объекты на контексте)

@property (strong, nonatomic, readonly) DSAdaptedObjectsFactory *modelsFactory;


#pragma mark - LOAD AND GET Objects
// Получение объектов из Базы данных

- (NSArray<DSBaseLoggedService*>*)getAllServices;
- (NSArray<DSJournal*>*)getAllJournals;
- (NSArray<DSJournalRecord*>*)getAllRecords;

- (DSJournal*)getJournalForName:(NSString*)journalName;
- (DSBaseLoggedService*)getServiceByTypeID:(NSNumber*)serviceTypeID orByClass:(NSString*)serviceClass;


@end
