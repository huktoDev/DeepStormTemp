//
//  DSAdaptedDBError.h
//  ReporterProject
//
//  Created by Alexandr Babenko on 22.07.16.
//  Copyright © 2016 Alexandr Babenko. All rights reserved.
//

#import <CoreData/CoreData.h>
@class DSAdaptedDBService;


/**
    @class DSAdaptedDBError
    @author HuktoDev
    @updated 21.07.2016
    @abstract Внутренняя модель ошибки сервиса для работы с БД и CoreData
    @discussion
    Содержит практически аналогичные поля, что и обычный сервис.
    Все поля этой модели содержатся в базе.
    Презентация обыкновенной NSError ошибки в БД
 
    @note
    Ошибка ассоциируется с каким-то конкретным сервисом, в котором она произошла
 */
@interface DSAdaptedDBError : NSManagedObject

@property (copy, nonatomic) NSNumber *code;
@property (copy, nonatomic) NSString *domain;
@property (copy, nonatomic) NSString *localizedDescription;
@property (copy, nonatomic) NSNumber *serialNumber;

@property (copy, nonatomic) NSError *embeddedError;

@property (strong, nonatomic) DSAdaptedDBService *parentService;

@end
