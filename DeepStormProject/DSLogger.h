////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/**
 *      DSLogger.h
 *      DeepStorm Framework
 *
 *      Created by Alexandr Babenko on 12.06.16.
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

#import <Foundation/Foundation.h>
#import "DSReporting.h"
#import "DSJournal.h"

/**
    @class DSLogger
    @author HuktoDev
    @updated 12.06.2016
    @abstract Класс-логгер, являющийся фасадом над основным набором задач DeepStorm-а
    @discussion
    Является синглтоном. 
    Позволяет 2 вещи :
    <ol type="1">
        <li> Добавлять запись в журнал с определенным названием </li>
        <li> Выполнять отправку разных репортов </li>
    </ol>
 
    @note Имеет удобные макросы, которые позволяют даже не использовать этот класс напрямую!
 */
@interface DSLogger : NSObject

#pragma mark - Initialization & Config
+ (instancetype)sharedLogger;


#pragma mark - ADD LOGS
// Добавление записей

- (void)addLogToJournalWithName:(NSString*)journalName withFormat:(NSString*)format, ...;
- (void)addLogToJournalWithName:(NSString*)journalName withDictionary:(NSDictionary*)logDictionary withFormat:(NSString*)format, ...;
- (void)addLogToJournalWithName:(NSString*)journalName withDictionary:(NSDictionary*)logDictionary withLogLevel:(DSRecordLogLevel)logLevel withFormat:(NSString*)format, ...;


#pragma mark - SEND LOGS
// Отправка репортов

- (void)sendReportWithReporter:(id<DSReporterProtocol>)reporter forJournalWithName:(NSString*)journalName;
- (void)sendReportWithReporter:(id<DSReporterProtocol>)reporter forJournalWithNames:(NSArray<NSString*>*)journalNames;
- (void)sendFullSystemReportageWithReporter:(id<DSReporterProtocol>)reporter;


@end

