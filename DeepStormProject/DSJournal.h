////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/**
 *      DSJournal.h
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
#import <Foundation/Foundation.h>
@class DSJournalRecord;

#define DEFAULT_MAX_STORED_RECORDS 500


/**
    @constant DSRecordLogLevelParamKey
        Можно передавать уровень логгирования через  userInfo, с помощью этого параметра
 */
extern NSString * const DSRecordLogLevelParamKey;


/**
    @class DSJournal
    @abstract Класс журнала, управляет и хранит записи
    @discussion
    Класс. собственно, выполняет 4 задачи (и используется повсеместно, центральный класс)
    <ol type="a">
        <li> Управление записями (DSJournalRecord) : Добавление / очистка журнала </li>
        <li> Создание базовых репортов (с выбором формата) </li>
        <li> Получение конкретной записи </li>
        <li> Если требуется - потоковое логгирование в консоль (с возможностью отключать логгирование для конкретного журнала)
    </ol>
 
    @note Кроме всего - следит за тем, чтобы журнал не содержал много записей, и очищает старые записи.
    <ul>
        <li> Можно конфигурировать максимальное количество записей с помощью maxCountStoredRecords </li>
        <li> Верхнее  граничное кол-во записей по-умолчанию - 500 (DEFAULT_MAX_STORED_RECORDS) </li>
    </ul>
 */
@interface DSJournal : NSObject{
    @protected
    NSMutableArray <DSJournalRecord*> *records;
}

@property (assign, nonatomic) BOOL outputLoggingDisabled;

@property (copy, nonatomic) NSString *journalName;
@property (assign, nonatomic) NSUInteger maxCountStoredRecords;

#pragma mark - Manipulate Records
// Добавление и удаление записей

- (void)addLogRecord:(NSString*)logString withInfo:(NSDictionary*)userInfo;
- (void)addLogWithInfo:(NSDictionary*)userInfo withFormat:(NSString*)format, ...;
- (void)clearJournal;


#pragma mark - Recieving Records
// Получение требуемых записей

@property (assign, nonatomic, readonly) NSUInteger countRecords;

- (DSJournalRecord*)getRecordWithNumber:(NSNumber*)numberRecord;
- (void)enumerateRecords:(void (^)(DSJournalRecord *))recordEnumerateBlock;
- (void)enumerateLast:(NSUInteger)countNeededRecords records:(void (^)(DSJournalRecord *))recordEnumerateBlock;

@end

