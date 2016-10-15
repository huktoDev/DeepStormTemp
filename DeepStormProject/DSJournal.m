////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/**
 *      DSJournal.m
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
#import "DSJournal.h"
#import "DSJournalRecord.h"
#import "DSJournalDefines.h"

NSString * const DSRecordLogLevelParamKey = @"DSRecordLogLevelParamKey";

@implementation DSJournal

#pragma mark - Config Journal

- (instancetype)init{
    if(self = [super init]){
        
        self.maxCountStoredRecords = DEFAULT_MAX_STORED_RECORDS;
        records = [NSMutableArray new];
    }
    return self;
}

- (NSString *)journalName{
    if(_journalName.length > 0){
        return [_journalName copy];
    }
    return @"Unnamed";
}

#pragma mark - Manipulate Records

/**
    @abstract Добавление  новой отформатированной записи в журнал
    @discussion
    Часто нужно более упрощенный способ добавить запись к журналу. Чтобы не создавать строку сначала, а только потом логгировать. Чтобы можно было формат и параметры формата передать в методе
 
    @param userInfo         Дополнительная информация к записи (словарь)
    @param format         Строка форматирования, далее к ней крепятся последовательность параметров. Результирующая строка будет добавлена в журнал
 */
- (void)addLogWithInfo:(NSDictionary*)userInfo withFormat:(NSString*)format, ...{
    
    if(format){
        va_list argsList;
        va_start(argsList, format);
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wformat-nonliteral"
        NSString *formattedLogMessage = [[NSString alloc] initWithFormat:format arguments:argsList];
#pragma clang diagnostic pop
        
        va_end(argsList);
        [self addLogRecord:formattedLogMessage withInfo:userInfo];
        
    }else{
        NSLog(@"Format Can Not be NIL !");
    }
}

/**
    @abstract Добавление новой записи в журнал
    @discussion
    Создает новую запись из переданной информации, затем синхронизированно добавляет в журнал
    Присваивает записи идентификатор (порядковый номер)
 
    @note в userInfo может содержаться
 
    @note Если включен в коде режим потокового логгирования DSJOURNAL_LOG_STREAMING - логгирует записи в консоль сразу при добавлении (еще требуется, чтобы outputLoggingDisabled = NO )
    
    @note Если записей становится слишком много - очищает записи порциями
 
    @param logString        Логгируемая строка (содержащая описание записи)
    @param userInfo         Дополнительная информация к записи (словарь)
 */
- (void)addLogRecord:(nonnull NSString*)logString withInfo:(nullable NSDictionary*)userInfo {
    
    if(! logString){
        NSAssert(NO, @"logString in LogRecord always must be not nil!");
        return;
    }
    
    DSJournalRecord *newRecord = [DSJournalRecord new];
    newRecord.recordDescription = logString;
    newRecord.recordDate = [NSDate date];
    
    // Добавить уровень логгирования, если имеется
    if(userInfo){
        
        NSMutableDictionary *filteredUserInfo = [[NSMutableDictionary alloc] initWithDictionary:userInfo];
        NSNumber *logLevel = userInfo[DSRecordLogLevelParamKey];
        if(logLevel){
            // Проверка log Level Value
            NSAssert([logLevel isKindOfClass:[NSNumber class]], @"Log Level is incorrect Type (not NSNumber)");
            
            DSRecordLogLevel recordLogLevel = [logLevel unsignedIntegerValue];
            NSAssert((recordLogLevel >= DSRecordLogLevelInfo && recordLogLevel <= DSRecordLogLevelError), @"Log Level Value is incorrect");
            
            [filteredUserInfo removeObjectForKey:DSRecordLogLevelParamKey];
            newRecord.recordLogLevel = recordLogLevel;
        }else{
            newRecord.recordLogLevel = DSRecordLogLevelDefault;
        }
        newRecord.recordInfo = (filteredUserInfo.count > 0) ? filteredUserInfo : nil;
        
    }else{
        newRecord.recordLogLevel = DSRecordLogLevelDefault;
        newRecord.recordInfo = userInfo;
    }
    
    // Добавить подготовленную запись
    [self _privateAddLogRecord:newRecord];
}

/**
    @abstract Приватное добавление нового объекта записи
    @discussion
    Вычисляется и устанавливается порядковый номер записи, обновляется очередь записей.
    Все это делается с блокировкой к массиву во время записи (чтобы 2 потока не пытались одновременно получить доступ)
    @param newRecord        Объект новой записи, которая будет добавлена
 */
- (void)_privateAddLogRecord:(DSJournalRecord*)newRecord{
    
    @synchronized(records) {
        
        // Присваивает записи порядковый номер
        DSJournalRecord *lastRecord = [records lastObject];
        NSUInteger newRecordNumber = lastRecord ? ([lastRecord.recordNumber unsignedIntegerValue] + 1) : 1;
        newRecord.recordNumber = @(newRecordNumber);
        
        // Очищает записи порциями
        if(records.count >= self.maxCountStoredRecords){
            [records removeObjectAtIndex:0];
        }
        [records addObject:newRecord];
    }
}

/// Безопасно очищает журнал (удаляет все записи)
- (void)clearJournal{
    @synchronized(records) {
        [records removeAllObjects];
    }
}

#pragma mark - Recieving Records

/// Получение количества записей в журнале
- (NSUInteger)countRecords{
    return records.count;
}

/// Получение записи по порядковому номеру (nil, если не найдена)
- (DSJournalRecord*)getRecordWithNumber:(NSNumber*)numberRecord{
    for (DSJournalRecord *logRecord in records) {
        if([logRecord.recordNumber isEqualToNumber:numberRecord]){
            return logRecord;
        }
    }
    return nil;
}

/// Энумерация всех записей в журнале с помощью блока
- (void)enumerateRecords:(void (^)(DSJournalRecord *))recordEnumerateBlock{
    
    if(! recordEnumerateBlock){
        return;
    }
    @synchronized(records) {
        for (DSJournalRecord *currentRecord in records) {
            recordEnumerateBlock(currentRecord);
        }
    }
}

- (void)enumerateLast:(NSUInteger)countNeededRecords records:(void (^)(DSJournalRecord *))recordEnumerateBlock{
    
    if(! recordEnumerateBlock){
        return;
    }
    @synchronized(records) {
        
        NSUInteger countLastRecords = (countNeededRecords <= records.count) ? countNeededRecords : records.count;
        NSArray <DSJournalRecord*> *croppedRecords = [records subarrayWithRange:NSMakeRange(records.count - countLastRecords, countLastRecords)];
        for (DSJournalRecord *currentRecord in croppedRecords) {
            recordEnumerateBlock(currentRecord);
        }
    }
}

@end
