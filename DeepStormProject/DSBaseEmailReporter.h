////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/**
 *      DSBaseEmailReporter.h
 *      DeepStorm Framework
 *
 *      Created by Alexandr Babenko on 20.07.16.
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
#import "DSEmailReporterProtocol.h"
#import "DSJournalMappingProtocol.h"
#import "DSSendingEventInterfaces.h"

#import "DSBaseEventBuiltInReporter.h"

@interface DSBaseEmailReporter : DSBaseEventBuiltInReporter <DSReporterProtocol, DSEmailReporterProtocol>


#pragma mark - DSEmailReporterProtocol
// Методы для отправки имейла

- (void)addDestinationEmail:(NSString*)destinationEmail;

- (void)sendEmailWithData:(NSData*)emailData withFilename:(NSString*)fileName;
- (void)sendEmailWithFileArray:(NSDictionary <NSString*, NSData*> *)filesDictionary;



#pragma mark -  DSSimpleReporterProtocol
// Методы для отправки простого репорта

- (void)sendReportJournal:(DSJournal *)reportingJournal;
- (void)sendReportService:(DSBaseLoggedService *)reportingService;



#pragma mark - DSComplexReporterProtocol
// Методы для отправки составного репорта

- (void)addPartReportJournal:(DSJournal*)reportingJournal;
- (void)addPartReportService:(DSBaseLoggedService*)reportingService;
- (void)performAllReports;


#pragma mark - DSReporterProtocol
// Коллбэк

@property (copy, nonatomic) DSReportingCompletionBlock reportingCompletion;


@end
