//
//  DSAdaptedDBError+Convertation.h
//  ReporterProject
//
//  Created by Alexandr Babenko on 22.07.16.
//  Copyright © 2016 Alexandr Babenko. All rights reserved.
//

#import "DSAdaptedDBError.h"


/**
    @category DSAdaptedDBError (Convertation)
    @author HuktoDev
    @updated 22.07.2016
    @abstract  Категория для конвертации моделей ошибок сервиса.
    @discussion
    1) NSError -> DSAdaptedDBError
    2) DSAdaptedDBError -> NSError
 
    @note
    - Для конвертации в DSAdaptedDBError требуется пустая базовая модель (blank)
    - Для создания внутренних дочерних моделей для DSAdaptedDBError в некоторых случаях нужна фабрика моделей
 */
@interface DSAdaptedDBError (Convertation)

+ (instancetype)adaptedModelForError:(NSError*)convertationError fromBlankModel:(DSAdaptedDBError*)blankAdaptedError;
- (NSError*)convertToError;

@end
