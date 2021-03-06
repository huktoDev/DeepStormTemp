//
//  DSLocalSQLDatabaseReporter.h
//  ReporterProject
//
//  Created by Alexandr Babenko on 21.07.16.
//  Copyright © 2016 Alexandr Babenko. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DSReporting.h"
#import "DSBaseEventBuiltInReporter.h"

#import "DSStoreDataProvidingProtocol.h"
@class DSLocalSQLDatabase;

// support of incremental protocol (simple one row transaction to DB)
// support of simple protocol (transaction to DB)
// support of complex protocol (many transactions to DB, sync)

@interface DSLocalSQLDatabaseReporter : DSBaseEventBuiltInReporter <DSReporterProtocol, DSStreamingEventExecutorProtocol>

+ (DSLocalSQLDatabaseReporter<DSStreamingEventFullProtocol>*)extendedDBReporter;
@property (strong, nonatomic, readonly) DSLocalSQLDatabase<DSStoreDataProvidingProtocol> *localDB;

@end
