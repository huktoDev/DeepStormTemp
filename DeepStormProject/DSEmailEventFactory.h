////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/**
 *      DSEmailEventFactory.h
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

#import <Foundation/Foundation.h>

#import "DSEventFactoryProtocol.h"

/**
    @class DSEmailEventFactory
    @author HuktoDev
    @updated 21.06.2016
    @abstract Класс-фабрика для создания события отправки на имейл
    @discussion
    Использует DSFileEventFactory внутри, что не оптимально. По идее не должно, на текущий момент только адаптирует модели файловых событий.
 */
@interface DSEmailEventFactory : NSObject <DSEventFactoryProtocol>

@end
