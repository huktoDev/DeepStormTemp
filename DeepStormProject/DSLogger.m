////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/**
 *      DSLogger.m
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

#import "DSLogger.h"

#import "DSExternalJournalCloud.h"
#import "DSServiceManager.h"
#import "DSBaseLoggedService.h"


@implementation DSLogger


#pragma mark - Initialization & Config

+ (instancetype)sharedLogger{
    
    static DSLogger *_sharedSystemLogger = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        _sharedSystemLogger = [DSLogger new];
    });
    return _sharedSystemLogger;
}


#pragma mark - ADD LOGS

/**
    @abstract Добавить запись в журнал по формату
    @discussion
    @note Полезно обернуть в макрос. Можно для каждого журнала делать свой макрос. Уже существует удобный макрос над этим методом : 
            DSJRN_LOG(journalName, ...);
    @note Если журнала с переданным названием нету - создает новый журнал
 
    @warning К сожалению, приходится каждый раз формировать из множественных параметров строку именно в этом методе
 
    @throw DSLoggingInternalException
        Если переданная строка для логгирования некорректна, или nil
 
    @param journalName    Название журнала, в который следует сделать новую запись
    @param format      Строка со знаками форматирования, и далее параметры для форматирования
 */
- (void)addLogToJournalWithName:(NSString*)journalName withFormat:(NSString*)format, ...{
    
    if(! format || ! [format isKindOfClass:[NSString class]]){
        @throw [NSException exceptionWithName:@"DSLoggingInternalException" reason:@"Format NSLog cannot be nil and should be NSString" userInfo:nil];
    }
    
    va_list argsList;
    va_start(argsList, format);
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wformat-nonliteral"
    NSString *formattedLogMessage = [[NSString alloc] initWithFormat:format arguments:argsList];
#pragma clang diagnostic pop
    
    va_end(argsList);
    
    [self addLogToJournalWithName:journalName withDictionary:nil withLogString:formattedLogMessage];
}

/**
    @abstract Добавить запись в журнал по формату
    @discussion
    @note Полезно обернуть в макрос. Можно для каждого журнала делать свой макрос. Уже существует удобный макрос над этим методом : 
            DSJRN_INFO_LOG(journalName, info, ...);
    @note Если журнала с переданным названием нету - создает новый журнал
 
    @warning К сожалению, приходится каждый раз формировать из множественных параметров строку именно в этом методе
 
    @throw DSLoggingInternalException
        Если переданная строка для логгирования некорректна, или nil
 
    @param journalName    Название журнала, в который следует сделать новую запись
    @param logDictionary     Словарь, с дополнительной информацией, прикрепляемый к записи
    @param format      Строка со знаками форматирования, и далее параметры для форматирования
 */
- (void)addLogToJournalWithName:(NSString*)journalName withDictionary:(NSDictionary*)logDictionary withFormat:(NSString*)format, ...{
    
    if(! format || ! [format isKindOfClass:[NSString class]]){
        @throw [NSException exceptionWithName:@"DSLoggingInternalException" reason:@"Format NSLog cannot be nil and should be NSString" userInfo:nil];
    }
    
    va_list argsList;
    va_start(argsList, format);
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wformat-nonliteral"
    NSString *formattedLogMessage = [[NSString alloc] initWithFormat:format arguments:argsList];
#pragma clang diagnostic pop
    
    va_end(argsList);
    
    [self addLogToJournalWithName:journalName withDictionary:logDictionary withLogString:formattedLogMessage];
}

/**
    @abstract Добавить запись в журнал по формату, и с заданным logLevel
    @discussion
    @note Полезно обернуть в макрос. Можно для каждого журнала делать свой макрос. Уже существует удобный макрос над этим методом :
        DSJRN_INFO_LOG(journalName, info, ...);
    @note Если журнала с переданным названием нету - создает новый журнал
    @note Создается новый словарь для userInfo, и добавляется в него параметром logLevel
 
    @warning К сожалению, приходится каждый раз формировать из множественных параметров строку именно в этом методе
 
    @throw DSLoggingInternalException
        Если переданная строка для логгирования некорректна, или nil
 
    @param journalName    Название журнала, в который следует сделать новую запись
    @param logDictionary     Словарь, с дополнительной информацией, прикрепляемый к записи
    @param logLevel      Уровень видимости (важности) записи
    @param format      Строка со знаками форматирования, и далее параметры для форматирования
 */
- (void)addLogToJournalWithName:(NSString*)journalName withDictionary:(NSDictionary*)logDictionary withLogLevel:(DSRecordLogLevel)logLevel withFormat:(NSString*)format, ... {
    
    if(! format || ! [format isKindOfClass:[NSString class]]){
        @throw [NSException exceptionWithName:@"DSLoggingInternalException" reason:@"Format NSLog cannot be nil and should be NSString" userInfo:nil];
    }
    
    va_list argsList;
    va_start(argsList, format);
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wformat-nonliteral"
    NSString *formattedLogMessage = [[NSString alloc] initWithFormat:format arguments:argsList];
#pragma clang diagnostic pop
    
    va_end(argsList);
    
    NSMutableDictionary *extendedUserInfo = [NSMutableDictionary dictionaryWithDictionary:logDictionary];
    [extendedUserInfo addEntriesFromDictionary:@{DSRecordLogLevelParamKey : @(logLevel)}];
    
    [self addLogToJournalWithName:journalName withDictionary:extendedUserInfo withLogString:formattedLogMessage];
}


/**
    @abstract Добавить запись в журнал
    @discussion
    Внутренний метод для логгирования (общий для обоих методов addLog  в открытом интерфейсе)
    Имеет жесткий внутренний контракт для параметров на входе
 
    @note Если журнала с переданным названием нету - создает новый журнал
 
    @param journalName    Название журнала, в который следует сделать новую запись
    @param logDictionary     Словарь, с дополнительной информацией, прикрепляемый к записи
    @param logString      Логгируемая строка (которую будем записывать в журнал)
 */
- (void)addLogToJournalWithName:(NSString*)journalName withDictionary:(NSDictionary*)logDictionary withLogString:(NSString*)logString{
    
    NSAssert(journalName, @"journalName in %s must be always not nil", __PRETTY_FUNCTION__);
    NSAssert([journalName isKindOfClass:[NSString class]], @"journalName in %s must be always NSString", __PRETTY_FUNCTION__);
    NSAssert(!logDictionary || (logDictionary && [logDictionary isKindOfClass:[NSDictionary class]]), @"logDictionary must be always NSDictionary");
    
    DSExternalJournalCloud *journalCloud = [DSExternalJournalCloud sharedCloud];
    DSJournal *currentJournal = [journalCloud journalByName:journalName];
    if(! currentJournal){
        currentJournal = [journalCloud createExternalJournalWithName:journalName];
    }
    
    [currentJournal addLogRecord:logString withInfo:logDictionary];
}



#pragma mark - SEND LOGS

/**
    @abstract Отправление репорта для журнала
    @discussion
    Находится журнал с соответствующим названием, и передается для отправки репорта соответствующему репортеру.
    В методе дествуют жесткие контракты на входе
 
    @note Имеется удобный макрос над этим методом : 
        DSREPORT_JRN(reporter, journalName);
 
    @param reporter      Репортер, который будет выполнять отправку
    @param journalName     Название журнала, который нужно отправить
 */
- (void)sendReportWithReporter:(id<DSReporterProtocol>)reporter forJournalWithName:(NSString*)journalName{
    
    NSAssert(journalName, @"journalName in %s must be always not nil", __PRETTY_FUNCTION__);
    NSAssert([journalName isKindOfClass:[NSString class]], @"journalName in %s must be always NSString", __PRETTY_FUNCTION__);
    
    SEL sendReportSelector = @selector(sendReportJournal:);
    BOOL reporterPrepared = [reporter respondsToSelector:sendReportSelector];
    NSAssert(reporterPrepared, @"reporter Not defined Method %@", NSStringFromSelector(sendReportSelector));
    
    DSJournal *currentJournal = [self getJournalWithName:journalName];
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [reporter performSelector:sendReportSelector withObject:currentJournal];
#pragma clang diagnostic pop
}

/**
    @abstract Отправление репорта для списка журналов
    @discussion
    Находятся журналы с соответствующими названиями, и передаются для отправки репорта соответствующему репортеру.
    В методе дествуют жесткие контракты на входе
 
    @param reporter      Репортер, который будет выполнять отправку
    @param journalNames     Массив названий журналов, которые нужно отправить
 */
- (void)sendReportWithReporter:(id<DSReporterProtocol>)reporter forJournalWithNames:(NSArray<NSString*>*)journalNames{
    
    SEL addPartSelector = @selector(addPartReportJournal:);
    BOOL reporterPrepared = [reporter respondsToSelector:addPartSelector];
    NSAssert(reporterPrepared, @"reporter Not defined Method %@", NSStringFromSelector(addPartSelector));
    
    SEL performSendingSelector = @selector(performAllReports);
    BOOL implementExecuteSending = [reporter respondsToSelector:performSendingSelector];
    NSAssert(implementExecuteSending, @"reporter  Not defined Method %@", NSStringFromSelector(performSendingSelector));
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    
    for (NSString *journalName in journalNames) {
        
        NSAssert([journalName isKindOfClass:[NSString class]], @"journalName in %s must be always NSString", __PRETTY_FUNCTION__);
        DSJournal *currentJournal = [self getJournalWithName:journalName];
        [reporter performSelector:addPartSelector withObject:currentJournal];
    }
    
    [reporter performSelector:performSendingSelector];
    
#pragma clang diagnostic pop
}

/**
    @abstract Отправление полного репортажа со всей системы
    @discussion
    <b> Репортится все : </b>
    <ol type="1">
        <li> Все журналы в расшаренном DSExternalJournalCloud </li>
        <li> Все сервисы расшаренного DSServiceManager </li>
    </ol>

    В методе дествуют жесткие контракты на входе.
    Все объекты последовательно крепятся к репорту с помощью DSComplexReporterProtocol
 
    @note Имеется удобный макрос над этим методом :
    DSREPORT_FULL(reporter);
 
    @param reporter      Репортер, который будет выполнять отправку
 */
- (void)sendFullSystemReportageWithReporter:(id<DSReporterProtocol>)reporter{
    
    DSExternalJournalCloud *journalCloud = [DSExternalJournalCloud sharedCloud];
    DSServiceManager *svcManager = [DSServiceManager sharedManager];
    
    BOOL isServicesExist = (!svcManager || svcManager.servicePool.count == 0);
    BOOL hasJournals = (journalCloud.journalNamesList.count > 0);
    NSAssert((isServicesExist || hasJournals), @"Reporter can not Send Report, System doesn't have any services and any journals!");
    
    SEL addPartSelector = @selector(addPartReportJournal:);
    BOOL reporterPrepared = [reporter respondsToSelector:addPartSelector];
    NSAssert(reporterPrepared, @"reporter Not defined Method %@", NSStringFromSelector(addPartSelector));
    
    SEL performSendingSelector = @selector(performAllReports);
    BOOL implementExecuteSending = [reporter respondsToSelector:performSendingSelector];
    NSAssert(implementExecuteSending, @"reporter  Not defined Method %@", NSStringFromSelector(performSendingSelector));
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    
    NSArray <NSString*> *allExternalJournalNames = journalCloud.journalNamesList;
    for (NSString *journalName in allExternalJournalNames) {
        
        DSJournal *currentJournal = [self getJournalWithName:journalName];
        [reporter performSelector:addPartSelector withObject:currentJournal];
    }
    
    [reporter performSelector:addPartSelector withObject:svcManager];
    [svcManager enumerateServices:^(id<DSServiceProtocol> currentService) {
        
        [reporter performSelector:addPartSelector withObject:currentService];
    }];
    
    [reporter performSelector:performSendingSelector];
    
#pragma clang diagnostic pop
}


#pragma mark - JOURNAL Recieving (Additional Method)

/**
    @abstract Получение журнала по имени
    @discussion
    Вспомогательный метод, использующийся в логгере для получения объекта журнала из имени. Помимо всего прочего, создает журнал, если его не находит.
 
    @param journalName     Название журнала
    @return Объект журнала с соответствующим названием
 */
- (DSJournal*)getJournalWithName:(NSString*)journalName{
    
    DSExternalJournalCloud *journalCloud = [DSExternalJournalCloud sharedCloud];
    DSJournal *currentJournal = [journalCloud journalByName:journalName];
    if(! currentJournal){
        currentJournal = [journalCloud createExternalJournalWithName:journalName];
    }
    return currentJournal;
}


@end
