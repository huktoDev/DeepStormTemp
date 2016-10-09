//
//  DSAdaptedDBService.h
//  ReporterProject
//
//  Created by Alexandr Babenko on 21.07.16.
//  Copyright © 2016 Alexandr Babenko. All rights reserved.
//

#import <CoreData/CoreData.h>
@class DSAdaptedDBJournal, DSAdaptedDBError;

/**
    @class DSAdaptedDBService
    @author HuktoDev
    @updated 21.07.2016
    @abstract Внутренняя модель сервиса для работы с БД и CoreData
    @discussion
    Содержит практически аналогичные поля, что и обычный сервис.
    Все поля этой модели содержатся в базе.
 
    @note
    - Может иметь внутри себя дочерний журнал собственных событий
    - Может иметь внутри себя информацию о произошедших ошибках
 
    @see DSBaseLoggedService
 */
@interface DSAdaptedDBService : NSManagedObject

@property (copy, nonatomic) NSString *serviceClass;
@property (copy, nonatomic) NSNumber *typeID;
@property (copy, nonatomic) NSString *workingMode;
@property (copy, nonatomic) NSNumber *countEmergencyErrors;

@property (strong, nonatomic) DSAdaptedDBJournal *journal;
@property (strong, nonatomic) NSMutableSet <DSAdaptedDBError*> *emergencyErrors;

// Назначенный сэттер
- (void)addEmergencyError:(DSAdaptedDBError*)newEmergencyError;

@end
