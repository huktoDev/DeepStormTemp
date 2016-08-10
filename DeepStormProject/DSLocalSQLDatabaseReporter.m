//
//  DSLocalSQLDatabaseReporter.m
//  ReporterProject
//
//  Created by Alexandr Babenko on 21.07.16.
//  Copyright © 2016 Alexandr Babenko. All rights reserved.
//

#import "DSLocalSQLDatabaseReporter.h"
#import "DSLocalSQLDatabase.h"

#import "DSJournal.h"
#import "DSBaseLoggedService.h"

#import "DSLocalSQLDatabaseEventFactory.h"
#import "DSStreamingDatabaseEvent.h"
#import "DSStreamingComplexEvent.h"

#import "DSEventSupportedProxyReporter.h"

@interface DSLocalSQLDatabaseReporter () <DSStreamingEventExecutorProtocol>

@property (strong, nonatomic, readwrite) DSLocalSQLDatabase *localDB;

@end

@implementation DSLocalSQLDatabaseReporter{
    
    @protected
    NSMutableArray <DSStreamingDatabaseEvent*> *_temporaryDBEvents;
}

@synthesize reportingCompletion=_reportingCompletion;


+ (DSLocalSQLDatabaseReporter<DSStreamingEventFullProtocol>*)extendedDBReporter{
    
    DSLocalSQLDatabaseReporter<DSStreamingEventFullProtocol> *newExtendedDBReporter = [[self class] new];
    return newExtendedDBReporter;
}

/// Задает фабрику транзакций для БД
- (instancetype)init{
    if(self = [super init]){
        [self registerEventFactoryClass:[DSLocalSQLDatabaseEventFactory class]];
        self.localDB = [DSLocalSQLDatabase sharedDeepStormLocalDatabase];
    }
    DSBaseEventBuiltInReporter<DSStreamingEventFullProtocol> *proxyReporter = [DSEventSupportedProxyReporter proxyReporterForEventReporter:self];
    return (DSLocalSQLDatabaseReporter*)proxyReporter;
}

- (void)sendReportJournal:(DSJournal*)reportingJournal{
    
    DSStreamingDatabaseEvent *dbEvent = [self eventForJournal:reportingJournal];
    [self executeStreamingEvent:dbEvent];
}

- (void)sendReportService:(DSBaseLoggedService*)reportingService{
    
    DSStreamingDatabaseEvent *dbEvent = [self eventForService:reportingService];
    [self executeStreamingEvent:dbEvent];
}


- (void)addPartReportJournal:(DSJournal*)reportingJournal{
    if(! _temporaryDBEvents){
        _temporaryDBEvents = [NSMutableArray new];
    }
    DSStreamingDatabaseEvent *dbEvent = [self eventForJournal:reportingJournal];
    [_temporaryDBEvents addObject:dbEvent];
}

- (void)addPartReportService:(DSBaseLoggedService*)reportingService{
    if(! _temporaryDBEvents){
        _temporaryDBEvents = [NSMutableArray new];
    }
    DSStreamingDatabaseEvent *dbEvent = [self eventForService:reportingService];
    [_temporaryDBEvents addObject:dbEvent];
}

- (void)performAllReports{
    
    DSStreamingComplexEvent *newComplexDBEvent = [DSStreamingComplexEvent eventWithSingeEventsArray:_temporaryDBEvents];
    [self executeStreamingEvent:newComplexDBEvent];
    _temporaryDBEvents = nil;
}

- (BOOL)executeStreamingEvent:(id<DSStreamingEventProtocol>)streamingEvent{
    
    BOOL isExecuteSuccess = [self.localDB executeStreamingEvent:streamingEvent];
    if(self.reportingCompletion){
        self.reportingCompletion(isExecuteSuccess, nil);
    }
    return YES;
}

/// Может ли данный репортер объединять события отправки в одно комплексное?
- (BOOL)canUnionAllStreamingEvents{
    return YES;
}

@end
