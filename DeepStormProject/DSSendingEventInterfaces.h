////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/**
 *      DSStreamingEventProtocol.h
 *      DeepStorm Framework
 *
 *      Created by Alexandr Babenko on 20.07.16.
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

#import "DSJournal.h"
#import "DSBaseLoggedService.h"


/**
    @protocol DSEventConvertibleEntity
    @author HuktoDev
    @updated 20.06.2016
    @abstract Протокол, который должна определять сущность, которую можно адаптировать в объект события
    @discussion
    Все основные сущности должны определять этот протокол.
    В данном случае - а) Журнал и б) Сервис
 */
@protocol DSEventConvertibleEntity <NSObject>
@end

@interface DSJournal () <DSEventConvertibleEntity>
@end

@interface DSBaseLoggedService () <DSEventConvertibleEntity>
@end


/**
    @protocol DSStreamingEventProtocol
    @author HuktoDev
    @updated 20.06.2016
    @abstract Специальный протокол, который должен определять любой объект события стриминга
 */
@protocol DSStreamingEventProtocol <NSObject>
@end


/**
    @protocol DSStreamingEventProductorProtocol
    @author HuktoDev
    @updated 20.06.2016
    @abstract Протокол, который должен определять любой производитель событий
    @discussion
    Имеется как простой метод создания события из конвертируемой сущности.
 
    @note
    Кроме всего прочего, некоторые события могут объединяться в комплексное событие.
    Может отвечать на вопрос, нужно ли объединять события
 */
@protocol DSStreamingEventProductorProtocol <NSObject>

@required
- (id<DSStreamingEventProtocol>)produceStreamingEventWithObject:(id<DSEventConvertibleEntity>)convertibleObject;

@optional
- (BOOL)canUnionAllStreamingEvents;

@end


/**
    @protocol DSStreamingEventExecutorProtocol
    @author HuktoDev
    @updated 20.06.2016
    @abstract Протокол, который должен определять любой обработчик событий (исполнитель)
    @discussion
    Содержит всего один метод - для обработки события. Должен возвращать результат : YES - если событие начало исполняться (оно по идее будет асинхронно). NO - если не начало (например: не хватает данных)
 */
@protocol DSStreamingEventExecutorProtocol <NSObject>

@required
- (BOOL)executeStreamingEvent:(id<DSStreamingEventProtocol>)streamingEvent;

@end


/**
    @protocol DSStreamingEventFullProtocol
    @author HuktoDev
    @updated 20.06.2016
    @abstract Общий протокол для объекта, который может выполнять весь спектр задач с событиями
 */
@protocol DSStreamingEventFullProtocol <DSStreamingEventProductorProtocol, DSStreamingEventExecutorProtocol>
@end



