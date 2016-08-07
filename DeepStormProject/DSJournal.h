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

/**
    @enum DSJournalFormatDescription типы форматирования записи
    
    @constant DSJournalShortDescription             Способ краткого описания записи (однострочного)
    @constant DSJournalExtendedDescription      Способ расширенного описания записи
 */
typedef NS_ENUM(NSUInteger, DSJournalFormatDescription) {
    DSJournalShortDescription,
    DSJournalExtendedDescription,
};

#define DEFAULT_MAX_STORED_RECORDS 500


/**
    @constant DSRecordLogLevelParamKey
        Можно передавать уровень логгирования через  userInfo, с помощью этого параметра
 */
extern NSString * const DSRecordLogLevelParamKey;

/**
    @enum DSRecordLogLevel
        Уровень логгирования конкретной записи
 
    @constant DSRecordLogLevelInfo
        Минимальный уровень видимости (видны только при самом детальном репорте)
    @constant DSRecordLogLevelVerbose
        Уровень видимости для записей низкой важности (различных событий)
    @constant DSRecordLogLevelMedium
        Средняя зона видимости записи
    @constant DSRecordLogLevelHard
        Достаточно широкая зона видимости записи
    @constant DSRecordLogLevelWarning
        Запись-предупреждение (видна практически всегда)
    @constant DSRecordLogLevelError
        Запись-ошибка (самый высокий тип важности)
 */
typedef NS_ENUM(NSUInteger, DSRecordLogLevel) {
    DSRecordLogLevelInfo = 0,
    DSRecordLogLevelVerbose,
    DSRecordLogLevelMedium,
    DSRecordLogLevelHard,
    DSRecordLogLevelWarning,
    DSRecordLogLevelError
};

/**
    @function DSLogLevelDescription
    @abstract Строковое описание LogLevel-а
 */
NSString* DSLogLevelDescription(DSRecordLogLevel logLevel);


/**
    @class DSJournalRecord
    @abstract Модель записи журнала
    @discussion
    Используется в журналах, содержит  различную требуемую информацию о записи
    
    @property recordNumber           Номер записи в журнале
    @property recordDescription     Конкретно описание записи в журнале
    @property recordDate                Конкретная дата, когда была создана запись
    @property recordInfo                  Дополнительная информация, крепящаяся к записи
    @property recordLogLevel          Уровень видимости записи (уровень важности)
 
    @note Может описывать  себя с помощью 2х типов форматирования на текущий момент : DSJournalFormatDescription
 */
@interface DSJournalRecord : NSObject


#pragma mark - Records Properties
// Различные свойства записи

@property (copy, nonatomic) NSNumber *recordNumber;
@property (copy, nonatomic) NSString *recordDescription;

@property (copy, nonatomic) NSDate *recordDate;
@property (copy, nonatomic) NSDictionary *recordInfo;

@property (assign, nonatomic) DSRecordLogLevel recordLogLevel;

#pragma mark - Description Records With Formatting
// Описание записей с различным форматированием

- (NSString*)shortTypeDescription;
- (NSString*)extendedTypeDescription;

- (NSString*)descriptionWithFormat:(DSJournalFormatDescription)descriptionFormat;

@end


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


#pragma mark - Create Reports
// Создание репортов

- (NSString*)getJournalWithFormatDescription:(DSJournalFormatDescription)descriptionFormat;
- (NSString*)getJournalLastRecords:(NSUInteger)countNeededRecords WithFormatDescription:(DSJournalFormatDescription)descriptionFormat;
- (NSString*)getDescriptionRecord:(NSNumber*)numberRecord withFormatDescription:(DSJournalFormatDescription)descriptionFormat;


#pragma mark - Recieving Records
// Получение требуемых записей

@property (assign, nonatomic, readonly) NSUInteger countRecords;

- (DSJournalRecord*)getRecordWithNumber:(NSNumber*)numberRecord;
- (void)enumerateRecords:(void (^)(DSJournalRecord *))recordEnumerateBlock;
- (void)enumerateLast:(NSUInteger)countNeededRecords records:(void (^)(DSJournalRecord *))recordEnumerateBlock;

@end
