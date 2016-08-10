////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/**
 *      DSEventSupportedEmailReporter.h
 *      DeepStorm Framework
 *
 *      Created by Alexandr Babenko on 21.07.16.
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

#import "DSBaseEmailReporter.h"

/**
    @class DSEventSupportedProxyReporter
    @author HuktoDev
    @updated 10.08.2016
    @abstract Класс-прослойка для репортеров, которые могут полностью стримить события
    @discussion
    Так получилось, что в DSBaseEmailReporter методы протокола DSStreamingEventFullProtocol уже реализованы, но находятся в приватном интерфейсе.
    Поэтому задача стояла следующим образом : Сделать мост между приватным интерфейсом суперкласса, и публичным интерфейсом данного класса.
    Сделал прокси объект-обертку над DSBaseEventBuiltInReporter инстансами, которая обладает всеми качествами DSBaseEventBuiltInReporter + публичный протокол работы с событиями
 
    @note
    Этот класс выполняет эту задачу - он делает видимым снаружи интерфейс стриминга, и этот прокси репортер можно подключать в качестве исполнителя или производителя событий к стримеру
 */
@interface DSEventSupportedProxyReporter : NSProxy <DSStreamingEventFullProtocol>

+ (DSBaseEventBuiltInReporter<DSStreamingEventFullProtocol>*)proxyReporterForEventReporter:(DSBaseEventBuiltInReporter<DSStreamingEventExecutorProtocol>*)eventReporter;

@end

