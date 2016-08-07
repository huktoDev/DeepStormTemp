////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/**
 *      DSStreamingInterfaces.h
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

#import "DSSendingEventInterfaces.h"
#import "DSJournal.h"
#import "DSBaseLoggedService.h"


@protocol DSReporterProtocol;

/**
    @protocol DSObservableEntity
    @author HuktoDev
    @updated 20.06.2016
    @abstract Протокол, который обязана иметь наблюдаемая сущность
    @discussion
    Основные сущности должны реализовывать этот протокол :
    Это объекты а) Журнала и б) Сервиса
 
    Интерфейс наследуется от DSEventConvertibleEntity (так что представляет его более расширенную версию)
    т.е. объект, который может наблюдаться - должен и конвертироваться в событие
 
    @see DSObservableStreamingInterface
 */
@protocol DSObservableEntity <DSEventConvertibleEntity>
@end

@interface DSJournal () <DSObservableEntity>
@end

@interface DSBaseLoggedService () <DSObservableEntity>
@end


/**
    @protocol DSBaseControlStateStreamingInterface
    @author HuktoDev
    @updated 20.06.2016
    @abstract Протокол для управления состоянием стриминга
    @discussion
    Мы можем включить/отключить стриминг. Соответственно, когда стриминг включен - события создаются, и исполняются. Иначе - нет.
 */
@protocol DSBaseControlStateStreamingInterface <DSStreamingEventFullProtocol>

@required

- (void)startStreaming;
- (void)stopStreaming;

@end


/**
    @protocol DSWrapperEventExecutionStreamingInterface
    @author HuktoDev
    @updated 20.06.2016
    @abstract Протокол для стримера. Стример может иметь исполнителя событий, но это опционально
 */
@protocol DSWrapperEventExecutionStreamingInterface <DSBaseControlStateStreamingInterface>

@optional
@property (strong, nonatomic) id<DSStreamingEventExecutorProtocol> eventExecutor;

@end


/**
    @protocol DSWrapperEventExecutionStreamingInterface
    @author HuktoDev
    @updated 20.06.2016
    @abstract Протокол для стримера. Стример может иметь производителя событий.
    @discussion
    Каждый стример имеет собственные объекты, которые он стримит, независимо от того, ведет он за ними наблюдение, стримит по таймеру, или имеет какой-либо более сложный триггер.
    Обработчик событий не может напрямую работать с этими объектами, и требует от специального производственного объекта, чтобы он адаптировал их для него (создал объект события).
 
    @note
    Наличие производителя - опционально, в ином случае стример сам может реализовать адаптацию объектов в события
 */
@protocol DSWrapperEventProductionStreamingInterface <DSBaseControlStateStreamingInterface>

@optional
@property (strong, nonatomic) id<DSStreamingEventProductorProtocol> eventProducer;

@end


/**
    @protocol DSEventDefinedStreaminginterface
    @author HuktoDev
    @updated 20.06.2016
    @abstract Объединенный протокол для стримера
    @discussion
    Каждый стример может иметь 0-1 исполнителя (либо делегировать исполнителю, либо исполнять сам)
    Каждый стример может иметь 0-1 производителя (либо делегировать производителю создание, либо самому производить)
 
    @note
    Используется множественное наследование интерфейсов
 */
@protocol DSEventDefinedStreaminginterface <DSWrapperEventExecutionStreamingInterface, DSWrapperEventProductionStreamingInterface>
@end


/**
    @protocol DSPeriodicStreamingInterface
    @author HuktoDev
    @updated 20.06.2016
    @abstract Интерфейс для периодического стримера (который стримит по таймеру)
    @discussion
    Каждый стример может иметь в себе набор объектов для стриминга, которые должны быть конвертируемы.
    Набором этих объектов должно быть можно управлять.
 
    Кроме всего прочего - требуется, чтобы была возможность настраивать частоту стриминга
 
    @note
    Наследуется от уже довольно широкого протокола DSEventDefinedStreaminginterface
 */
@protocol DSPeriodicStreamingInterface <DSEventDefinedStreaminginterface>

@required

@property (strong, nonatomic) NSMutableArray <id<DSEventConvertibleEntity>> *streamingEntitiesArray;
- (void)addStreamingEntity:(id<DSEventConvertibleEntity>)newEntity;

@property (assign, nonatomic) NSTimeInterval streamingEventInterval;

@end



/**
    @protocol DSObservableStreamingInterface
    @author HuktoDev
    @updated 20.06.2016
    @abstract Интерфейс для стримера-наблюдателя (который следит за изменениями объектов, и стримит их в момент изменения)
    @discussion
    Подобный стример должен содержать в себе набор сущностей, за которыми он ведет наблюдение.
    Он должен  иметь также возможность управления ими
 
    @note
    Наследуется от уже довольно широкого протокола DSEventDefinedStreaminginterface
 */
@protocol DSObservableStreamingInterface <DSEventDefinedStreaminginterface>

@optional

@property (strong, nonatomic, readonly) NSMutableArray <id<DSObservableEntity>> *observableEntitiesArray;
- (void)addObservableEntity:(id<DSObservableEntity>)newEntity;

@end



