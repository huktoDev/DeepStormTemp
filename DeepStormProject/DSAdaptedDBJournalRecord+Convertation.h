//
//  DSAdaptedDBJournalRecord+Convertation.h
//  ReporterProject
//
//  Created by Alexandr Babenko on 22.07.16.
//  Copyright © 2016 Alexandr Babenko. All rights reserved.
//


#import "DSAdaptedDBJournalRecord.h"

@class DSAdaptedObjectsFactory;
@class DSJournalRecord;


/**
    @category DSAdaptedDBJournalRecord (Convertation)
    @author HuktoDev
    @updated 22.07.2016
    @abstract  Категория для конвертации моделей записей журнала.
    @discussion
    1) DSJournalRecord -> DSAdaptedDBJournalRecord
    2) DSAdaptedDBJournalRecord -> DSJournalRecord
 
    @note
    - Для конвертации в DSAdaptedDBJournalRecord требуется пустая базовая модель (blank)
    - Для создания внутренних дочерних моделей для DSAdaptedDBJournalRecord в некоторых случаях нужна фабрика моделей
 */
@interface DSAdaptedDBJournalRecord (Convertation)

+ (instancetype)adaptedModelForRecord:(DSJournalRecord*)convertingRecord fromBlankModel:(DSAdaptedDBJournalRecord*)blankAdaptedRecord;
- (DSJournalRecord*)convertToJournalRecord;

@end

