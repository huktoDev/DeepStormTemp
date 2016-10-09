//
//  DSAdaptedDBService+Convertation.h
//  ReporterProject
//
//  Created by Alexandr Babenko on 22.07.16.
//  Copyright © 2016 Alexandr Babenko. All rights reserved.
//

#import "DSAdaptedDBService.h"

@class DSAdaptedObjectsFactory;
@class DSBaseLoggedService;

/**
    @category DSAdaptedDBService (Convertation)
    @author HuktoDev
    @updated 22.07.2016
    @abstract  Категория для конвертации моделей сервиса.
    @discussion
    1) DSBaseLoggedService -> DSAdaptedDBService
    2) DSAdaptedDBService -> DSBaseLoggedService
 
    @note
    - Для конвертации в DSAdaptedDBService требуется пустая базовая модель (blank)
    - Для создания внутренних дочерних моделей для DSAdaptedDBService в некоторых случаях нужна фабрика моделей
 */
@interface DSAdaptedDBService (Convertation)

+ (instancetype)adaptedModelForService:(DSBaseLoggedService*)convertingService fromBlankModel:(DSAdaptedDBService*)blankAdaptedService andModelsFactory:(DSAdaptedObjectsFactory*)modelsFactory;
- (DSBaseLoggedService*)convertToService;

@end
