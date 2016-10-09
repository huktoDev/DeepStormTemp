//
//  DSAdaptedDBJournal.h
//  ReporterProject
//
//  Created by Alexandr Babenko on 21.07.16.
//  Copyright © 2016 Alexandr Babenko. All rights reserved.
//

#import <CoreData/CoreData.h>
@class DSAdaptedDBService;

/**
    @class DSAdaptedDBJournal
    @author HuktoDev
    @updated 21.07.2016
    @abstract Внутренняя модель журнала для работы с БД и CoreData
    @discussion
    Содержит практически аналогичные поля, что и обычный журнал.
    Все поля этой модели содержатся в базе.
 
    @note
    - Может иметь родительский сервис (ассоциироваться с конкретным сервисом)
    - Содержит основные данные - дочерние записи журнала
 
    @see DSJournal
 */
@interface DSAdaptedDBJournal : NSManagedObject

@property (copy, nonatomic) NSString *journalName;
@property (copy, nonatomic) NSString *journalClass;
@property (copy, nonatomic) NSNumber *currentCount;
@property (copy, nonatomic) NSNumber *maxCount;
@property (copy, nonatomic) NSNumber *outputStreamingState;

@property (strong, nonatomic) DSAdaptedDBService *parentService;
@property (strong, nonatomic) NSMutableSet *childRecords;

@end
