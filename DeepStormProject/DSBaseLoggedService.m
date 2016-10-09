////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/**
 *      DSBaseLoggedService.m
 *      DeepStorm Framework
 *
 *      Created by Alexandr Babenko on 27.02.16.
 *      Copyright © 2016 Alexandr Babenko. All rights reserved.
 *
 *      Licensed under the Apache License, Version 2.0 (the "License");
 *      you may not use this file except in compliance with the License.
 *      You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *      Unless required by applicable law or agreed to in writing, software
 *      distributed under the License is distributed on an "AS IS" BASIS,
 *      WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *      See the License for the specific language governing permissions and
 *      limitations under the License.
 */
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#import "DSBaseLoggedService.h"

NSString *serviceWorkingModeDescription(DSServiceWorkingMode workingMode){
    
    switch (workingMode) {
        case DSServiceNormalWork:
            return @"WORKING IN NORMAL MODE";
        case DSServiceLightError:
            return @"WORKING WITH LIGHT ERRORS MODE!!!";
        case DSServiceCriticalError:
            return @"STOP WORKED WITH CRITICAL ERRORS !!!";
        default:
            return @"WORK IN UNKNOWN MODE";
    }
}

@implementation DSBaseLoggedService

@synthesize logJournal;
@synthesize emergencySituationsErrors, workingMode;
@synthesize serviceType;

- (instancetype)init{
    if(self = [super init]){
        self.baseLogRepoter = [DSOutputConsoleReporter new];
    }
    return self;
}

#pragma mark - DSServiceWorkingProtocol

/// Фиксировать "нарушение" жизнедеятельности сервиса
- (void)fixateEmergercySituationWithError:(NSError*)emergencyError{
    
    if(! self.emergencySituationsErrors){
        self.emergencySituationsErrors = [NSMutableArray new];
    }
    [self.emergencySituationsErrors addObject:emergencyError];
}

- (void)changeWorkingMode:(DSServiceWorkingMode)newWorkingMode{
    self.workingMode = newWorkingMode;
}

#pragma mark - WORK WIH SERVICE LOGS

/// Добавить новый лог (метод-враппер)
- (void)log:(NSString*)logString{
    
    [self log:logString withInfo:nil];
}

/// Добавить новый лог с userInfo
- (void)log:(NSString *)logString withInfo:(NSDictionary *)userInfo{
    
    if(! self.logJournal){
        self.logJournal = [DSJournal new];
        if([[self class] isSubclassOfClass:[DSBaseLoggedService class]]){
            self.logJournal.journalName = NSStringFromClass([self class]);
        }
    }
    [self.logJournal addLogRecord:logString withInfo:userInfo];
}

/// Очистить журнл сервиса от всех записей
- (void)clearJournal{
    
    [self.logJournal clearJournal];
}

#pragma mark - Send Reports
// Основные методы репорта

- (void)sendServiceJournalReport:(id<DSReporterProtocol>)customReporter{
    
    BOOL canReporterSendJournalReport = [customReporter respondsToSelector:@selector(sendReportJournal:)];
    NSAssert(canReporterSendJournalReport, @"Reporter not defined sendReportJournal: Method !!!");
    
    [customReporter sendReportJournal:self.logJournal];
}

- (void)sendServiceWorkReport:(id<DSReporterProtocol>)customReporter{
    
    BOOL canReporterSendWorkReport = [customReporter respondsToSelector:@selector(sendReportService:)];
    NSAssert(canReporterSendWorkReport, @"Reporter not defined sendReportService: Method !!!");
    
    [customReporter sendReportService:self];
}


@end






