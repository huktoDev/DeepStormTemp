//
//  DSJournalRecord.h
//  DeepStormProject
//
//  Created by Alexandr Babenko (HuktoDev) on 09.10.16.
//  Copyright © 2016 Alexandr Babenko. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
    @enum DSRecordLogLevel
    @abstract Уровень логгирования конкретной записи
 
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
 
    @constant DSRecordLogLevelLowest
        Самый незначимый уровень видимости
    @constant DSRecordLogLevelHighest
        Самый высокий уровень видимости
    @constant DSRecordLogLevelDefault
        Уровень видимости, установленный по-умолчанию
 */
typedef NS_ENUM(NSUInteger, DSRecordLogLevel) {
    DSRecordLogLevelInfo = 0,
    DSRecordLogLevelVerbose,
    DSRecordLogLevelMedium,
    DSRecordLogLevelHard,
    DSRecordLogLevelWarning,
    DSRecordLogLevelError,
    
    DSRecordLogLevelLowest = DSRecordLogLevelInfo,
    DSRecordLogLevelHighest = DSRecordLogLevelError,
    DSRecordLogLevelDefault = DSRecordLogLevelVerbose
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
 */
@interface DSJournalRecord : NSObject


#pragma mark - Records Properties
// Различные свойства записи

@property (strong, nonatomic) NSNumber *recordNumber;
@property (copy, nonatomic) NSString *recordDescription;

@property (copy, nonatomic) NSDate *recordDate;
@property (copy, nonatomic) NSDictionary *recordInfo;

@property (assign, nonatomic) DSRecordLogLevel recordLogLevel;

@end


