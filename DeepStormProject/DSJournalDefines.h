////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/**
 *      DSJournalMacroses.h
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

#ifndef DSJournalMacroses_h
#define DSJournalMacroses_h


/**
    @def DSJOURNAL_LOG_STREAMING
        Включен ли режим логгирования (пкогда запись записывается в журнал - она автоматически воспроизводится с помощью выбранного DSLOGGER_STREAM_MACRO)
    @def DSLOGGER_STREAM_MACRO
        Когда запись записывается в любой из журналов - если включено потокове логгирование ее можно перенаправить еще в Output, например
 */

#define DSJOURNAL_LOG_STREAMING 1

#if DSJOURNAL_LOG_STREAMING == 1
    #define DSLOGGER_STREAM_MACRO     NSLog
#else
    #undef DSLOGGER_STREAM_MACRO
#endif


//MARK: писать логи только через эту строку, потому-что с ней можно сделать undef

/**
    @def DSJOURNAL_LOGGING_ON
        Включать ли DeepStorm логгирование
    @def DSJOURNAL_LOG
        Включен ли DeepStorm логгирование (всегда 0 на RELEASE-конфигурации)
 */

#define DSJOURNAL_LOGGING_ON 1

#define DSJOURNAL_LOG (DEBUG == 1 && DSJOURNAL_LOGGING_ON == 1)

typedef void (^DSSimpleBlockCode)(void);
static inline void journal_code(DSSimpleBlockCode blockCode){
#if DSJOURNAL_LOG == 1
    blockCode();
#endif
}

/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  ++++++++++ DEPRECATED макросы (старые макросы в 1.0) +++++++++
  ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
#pragma mark - OLD Macroses, DEPRECATED

#if DSJOURNAL_LOG

    #define DSJOURNALLING(a); journal_code(a);
    #define DSLOG_SERVICE(service, logString); [service log:logString];
    #define DSLOG_SERVICE_INFO(service, logString, info); [service log:logString withInfo:info];
    #define DSJOURNALLING_LOG(...); DSJOURNALLING((^{ \
        NSString *logString = [NSString stringWithFormat:__VA_ARGS__]; \
        DSLOG_SERVICE(self, logString); \
    }));

#else
    #define DSJOURNALLING(a);
    #define DSLOG_SERVICE(service, logString);
    #define DSLOG_SERVICE_INFO(service, logString, info);
    #define DSJOURNALLING_LOG(...);

#endif


/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 ++++++++++ НОВЫЕ макросы для Логгирования СЕРВИСОВ ++++++++
 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
#pragma mark - NEW SVC Macroses

#if DSJOURNAL_LOG

    #define LOG_LEVEL_STRING_KEY    DSRecordLogLevelParamKey

    #define DSSVC_LOG(...); DSJOURNALLING_LOG(__VA_ARGS__);

    #define DSSVC_EXT_LOG(info, ...); DSJOURNALLING((^{ \
        NSString *logString = [NSString stringWithFormat:__VA_ARGS__]; \
        DSLOG_SERVICE_INFO(self, logString, info); \
    }));

    #define DSSVC_INFO_LOG(...);        DSSVC_EXT_LOG(@{LOG_LEVEL_STRING_KEY : @(DSRecordLogLevelInfo)}, __VA_ARGS__);
    #define DSSVC_VERBOSE_LOG(...);     DSSVC_EXT_LOG(@{LOG_LEVEL_STRING_KEY : @(DSRecordLogLevelVerbose)}, __VA_ARGS__);
    #define DSSVC_MEDIUM_LOG(...);      DSSVC_EXT_LOG(@{LOG_LEVEL_STRING_KEY : @(DSRecordLogLevelMedium)}, __VA_ARGS__);
    #define DSSVC_HARD_LOG(...);        DSSVC_EXT_LOG(@{LOG_LEVEL_STRING_KEY : @(DSRecordLogLevelHard)}, __VA_ARGS__);
    #define DSSVC_WARNING_LOG(...);     DSSVC_EXT_LOG(@{LOG_LEVEL_STRING_KEY : @(DSRecordLogLevelWarning)}, __VA_ARGS__);
    #define DSSVC_ERROR_LOG(...);       DSSVC_EXT_LOG(@{LOG_LEVEL_STRING_KEY : @(DSRecordLogLevelError)}, __VA_ARGS__);

    #define DSSVC_EXT_LEVEL_LOG(info, logLevel, ...); DSJOURNALLING((^{ \
        NSDictionary *extUserDict = [[NSMutableDictionary dictionaryWithDictionary:info] addEntriesFromDictionary:@{LOG_LEVEL_STRING_KEY : @(logLevel)}]; \
        NSString *logString = [NSString stringWithFormat:__VA_ARGS__]; \
        DSLOG_SERVICE_INFO(self, logString, extUserDict); \
    }));

    #define DSSVC_INFO_EXT_LOG(info, ...);      DSSVC_EXT_LEVEL_LOG(info, DSRecordLogLevelInfo, __VA_ARGS__);
    #define DSSVC_VERBOSE_EXT_LOG(info, ...);   DSSVC_EXT_LEVEL_LOG(info, DSRecordLogLevelVerbose, __VA_ARGS__);
    #define DSSVC_MEDIUM_EXT_LOG(info, ...);        DSSVC_EXT_LEVEL_LOG(info, DSRecordLogLevelMedium, __VA_ARGS__);
    #define DSSVC_HARD_EXT_LOG(info, ...);          DSSVC_EXT_LEVEL_LOG(info, DSRecordLogLevelHard, __VA_ARGS__);
    #define DSSVC_WARNING_EXT_LOG(info, ...);       DSSVC_EXT_LEVEL_LOG(info, DSRecordLogLevelWarning, __VA_ARGS__);
    #define DSSVC_ERROR_EXT_LOG(info, ...);         DSSVC_EXT_LEVEL_LOG(info, DSRecordLogLevelError, __VA_ARGS__);

#else
    #define DSSVC_LOG(...);
    #define DSSVC_EXT_LOG(info, ...);

    #define DSSVC_INFO_LOG(...);
    #define DSSVC_VERBOSE_LOG(...);
    #define DSSVC_MEDIUM_LOG(...);
    #define DSSVC_HARD_LOG(...);
    #define DSSVC_WARNING_LOG(...);
    #define DSSVC_ERROR_LOG(...);

    #define DSSVC_EXT_LEVEL_LOG(info, logLevel, ...);

    #define DSSVC_INFO_EXT_LOG(info, ...);
    #define DSSVC_VERBOSE_EXT_LOG(info, ...);
    #define DSSVC_MEDIUM_EXT_LOG(info, ...);
    #define DSSVC_HARD_EXT_LOG(info, ...);
    #define DSSVC_WARNING_EXT_LOG(info, ...);
    #define DSSVC_ERROR_EXT_LOG(info, ...);
#endif


/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 ++++++++++ НОВЫЕ макросы для Логгирования ЖУРНАЛОВ ++++++++
 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
#pragma mark - NEW JRN Macroses

#if DSJOURNAL_LOG
    #define DSJRN_LOG(journalName, ...); [[DSLogger sharedLogger] addLogToJournalWithName:journalName withFormat:__VA_ARGS__];
    #define DSJRN_EXT_LOG(journalName, info, ...); [[DSLogger sharedLogger] addLogToJournalWithName:journalName withDictionary:info withFormat:__VA_ARGS__];

    #define DSJRN_INFO_LOG(journalName, ...);        DSJRN_EXT_LOG(journalName, @{LOG_LEVEL_STRING_KEY : @(DSRecordLogLevelInfo)}, __VA_ARGS__);
    #define DSJRN_VERBOSE_LOG(journalName, ...);     DSJRN_EXT_LOG(journalName, @{LOG_LEVEL_STRING_KEY : @(DSRecordLogLevelVerbose)}, __VA_ARGS__);
    #define DSJRN_MEDIUM_LOG(journalName, ...);      DSJRN_EXT_LOG(journalName, @{LOG_LEVEL_STRING_KEY : @(DSRecordLogLevelMedium)}, __VA_ARGS__);
    #define DSJRN_HARD_LOG(journalName, ...);        DSJRN_EXT_LOG(journalName, @{LOG_LEVEL_STRING_KEY : @(DSRecordLogLevelHard)}, __VA_ARGS__);
    #define DSJRN_WARNING_LOG(journalName, ...);     DSJRN_EXT_LOG(journalName, @{LOG_LEVEL_STRING_KEY : @(DSRecordLogLevelWarning)}, __VA_ARGS__);
    #define DSJRN_ERROR_LOG(journalName, ...);       DSJRN_EXT_LOG(journalName, @{LOG_LEVEL_STRING_KEY : @(DSRecordLogLevelError)}, __VA_ARGS__);


    #define DSJRN_EXT_LEVEL_LOG(journalName, info, logLevel, ...); DSJOURNALLING((^{ \
        NSMutableDictionary *extUserDict = [NSMutableDictionary dictionaryWithDictionary:info]; \
        [extUserDict addEntriesFromDictionary:@{LOG_LEVEL_STRING_KEY : @(logLevel)}]; \
        DSJRN_EXT_LOG(journalName, extUserDict, __VA_ARGS__); \
    }));

    #define DSJRN_INFO_EXT_LOG(journalName, info, ...);         DSJRN_EXT_LEVEL_LOG(journalName, info, DSRecordLogLevelInfo, __VA_ARGS__);
    #define DSJRN_VERBOSE_EXT_LOG(journalName, info, ...);      DSJRN_EXT_LEVEL_LOG(journalName, info, DSRecordLogLevelVerbose, __VA_ARGS__);
    #define DSJRN_MEDIUM_EXT_LOG(journalName, info, ...);       DSJRN_EXT_LEVEL_LOG(journalName, info, DSRecordLogLevelMedium, __VA_ARGS__);
    #define DSJRN_HARD_EXT_LOG(journalName, info, ...);         DSJRN_EXT_LEVEL_LOG(journalName, info, DSRecordLogLevelHard, __VA_ARGS__);
    #define DSJRN_WARNING_EXT_LOG(journalName, info, ...);      DSJRN_EXT_LEVEL_LOG(journalName, info, DSRecordLogLevelWarning, __VA_ARGS__);
    #define DSJRN_ERROR_EXT_LOG(journalName, info, ...);        DSJRN_EXT_LEVEL_LOG(journalName, info, DSRecordLogLevelError, __VA_ARGS__);

#else
    #define DSJRN_LOG(journalName, ...);
    #define DSJRN_EXT_LOG(journalName, info, ...);

    #define DSJRN_INFO_LOG(journalName, ...);
    #define DSJRN_VERBOSE_LOG(journalName, ...);
    #define DSJRN_MEDIUM_LOG(journalName, ...);
    #define DSJRN_HARD_LOG(journalName, ...);
    #define DSJRN_WARNING_LOG(journalName, ...);
    #define DSJRN_ERROR_LOG(journalName, ...);

    #define DSJRN_EXT_LEVEL_LOG(journalName, info, logLevel, ...);

    #define DSJRN_INFO_EXT_LOG(journalName, info, ...);
    #define DSJRN_VERBOSE_EXT_LOG(journalName, info, ...);
    #define DSJRN_MEDIUM_EXT_LOG(journalName, info, ...);
    #define DSJRN_HARD_EXT_LOG(journalName, info, ...);
    #define DSJRN_WARNING_EXT_LOG(journalName, info, ...);
    #define DSJRN_ERROR_EXT_LOG(journalName, info, ...);
#endif


/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 ++++++++++++++++ МАКРОСЫ для отправки репортов ++++++++++++++
 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
#pragma mark - REPORTING Macroses

#if DSJOURNAL_LOG
    #define DSREPORT_FULL(reporter); [[DSLogger sharedLogger] sendFullSystemReportageWithReporter:reporter];
    #define DSREPORT_JRN(reporter, journalName); [[DSLogger sharedLogger] sendReportWithReporter:reporter forJournalWithName:journalName];
#else
    #define DSREPORT_FULL(reporter);
    #define DSREPORT_JRN(reporter, journalName);
#endif




#endif


