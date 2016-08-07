////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/**
 *      DSBaseEventBuiltInReporter.h
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
#import "DSSendingEventInterfaces.h"
#import "DSEventFactoryProtocol.h"

#import "DSBaseMappingReporter.h"


/**
    @protocol DSReporterEventRecievingProtocol
    @author HuktoDev
    @updated  21.06.2016
    @abstract Протокол, который позволяет создавать события отправки из различных пригодных для этого объектов
 */
@protocol DSReporterEventRecievingProtocol <NSObject>

@required
- (id<DSStreamingEventProtocol>)eventForJournal:(DSJournal*)workJournal;
- (id<DSStreamingEventProtocol>)eventForService:(DSBaseLoggedService*)workService;
- (id<DSStreamingEventProtocol>)eventForRecords:(NSArray<DSJournalRecord*>*)workRecords withParentEntity:(id<DSEventConvertibleEntity>)parentEntity;

//TODO: eventWithConvertibleObject withParentEntity: (один метод входа)

@end


/**
    @class DSBaseEventBuiltInReporter
    @author HuktoDev
    @updated 21.06.2016
    @abstract Класс-фундамент для всех репортерах, которые используют события
    @discussion
    События создаются практически автоматически, для этого нужно указать только класс фабрики, которая реализует определенный фабричный протокол.
 
    @note Для большинства репортеров является одним из основных суперклассов
 */
@interface DSBaseEventBuiltInReporter : DSBaseMappingReporter <DSReporterEventRecievingProtocol>

- (void)registerEventFactoryClass:(Class<DSEventFactoryProtocol>)factoryClass;

@end


