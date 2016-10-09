//
//  DSAdaptedDBJournal+Convertation.h
//  ReporterProject
//
//  Created by Alexandr Babenko on 22.07.16.
//  Copyright © 2016 Alexandr Babenko. All rights reserved.
//

#import "DSAdaptedDBJournal.h"

@class DSJournal;
@class DSAdaptedObjectsFactory;

/**
    @category DSAdaptedDBJournal (Convertation)
    @author HuktoDev
    @updated 22.07.2016
    @abstract  Категория для конвертации моделей журнала.
    @discussion
    1) DSJournal -> DSAdaptedDBJournal
    2) DSAdaptedDBJournal -> DSJournal
 
    @note 
    - Для конвертации в DSAdaptedDBJournal требуется пустая базовая модель (blank)
    - Для создания внутренних дочерних моделей для DSAdaptedDBJournal в некоторых случаях нужна фабрика моделей
 */
@interface DSAdaptedDBJournal (Convertation)

+ (instancetype)adaptedModelForJournal:(DSJournal*)convertingJournal fromBlankModel:(DSAdaptedDBJournal*)blankAdaptedJournal andModelsFactory:(DSAdaptedObjectsFactory*)modelsFactory;
- (DSJournal*)convertToJournal;


@end
