//
//  DSLocalSQLDatabaseReporter.m
//  ReporterProject
//
//  Created by Alexandr Babenko on 21.07.16.
//  Copyright © 2016 Alexandr Babenko. All rights reserved.
//

#import "DSLocalSQLDatabaseReporter.h"

#import "DSJournal.h"
#import "DSBaseLoggedService.h"

#import "DSStreamingDatabaseEvent.h"

@implementation DSLocalSQLDatabaseReporter

/// Задает фабрику событий отправки имейлов
- (instancetype)init{
    if(self = [super init]){
        [self registerEventFactoryClass:[DSEmailEventFactory class]];
    }
    return self;
}

- (void)sendReportJournal:(DSJournal*)reportingJournal{
    
    
}

- (void)sendReportService:(DSBaseLoggedService*)reportingService{
    
    DSStreamingDatabaseEvent *dbEvent = [self eventForService:reportingService];
    [self executeStreamingEvent:emailEvent];
}

- (BOOL)executeStreamingEvent:(id<DSStreamingEventProtocol>)streamingEvent{
    
    
}

@end
