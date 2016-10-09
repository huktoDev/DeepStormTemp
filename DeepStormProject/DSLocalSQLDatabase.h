//
//  DSLocalSQLDatabase.h
//  ReporterProject
//
//  Created by Alexandr Babenko on 21.07.16.
//  Copyright © 2016 Alexandr Babenko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DSStoreDataProvidingProtocol.h"
#import "DSSendingEventInterfaces.h"


/**
    @class DSLocalSQLDatabase
    @author HuktoDev
    @updated 28.08.2016
    @abstract База данных для DeepStorm-а
    @discussion
    Класс, инкапсулирующий в себе всю работу с Core Data. Принимает на вход события(транзакции) репортера, и запоминает принятные объекты.
    Использует в себе :
    - Статический провайдер сущностей, содержащий всю информациию о модели данных
    - Фабрика заготовок объектов, автоматически инжектированных в контекст
 
    Предоставляет протокол для получения объектов из БД
    @see DSStoreDataProvidingProtocol
 */
@interface DSLocalSQLDatabase : NSObject <DSStreamingEventExecutorProtocol, DSStoreDataProvidingProtocol>


#pragma mark - Construction
+ (instancetype)sharedDeepStormLocalDatabase;


#pragma mark - DSStreamingEventExecutorProtocol IMP
// Локальная БД способна обрабатывать транзакции определенного типа

- (BOOL)executeStreamingEvent:(id<DSStreamingEventProtocol>)databaseEvent;
//TODO: make Pull Request


@end

