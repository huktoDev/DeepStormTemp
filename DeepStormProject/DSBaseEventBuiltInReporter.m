////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/**
 *      DSBaseEventBuiltInReporter.m
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

#import "DSBaseEventBuiltInReporter.h"

@interface DSBaseEventBuiltInReporter () <DSStreamingEventProductorProtocol>

@end

@implementation DSBaseEventBuiltInReporter{
    
    id<DSEventFactoryProtocol> eventFactory;
}

#pragma mark - SET EVENT Factory

/**
    @abstract Метод регистрирует тип фабрики событий для данного репортера
    @discussion
    Требуется специальный объект, чтобы производить события для репортера - с помощью этого метода задается тип этого объекта, и внутри создается сам объект.
    Каждый репортер, наследуемый от данного - обязан определить себе класс фабрики событий.
 
    @warning 
    Если тип будет неопределен (этот метод не вызван для подклассов) - при попытке сгенерировать событие будет возникать Exception
 
    @param factoryClass      Метакласс фабрики, должен иметь интерфейс DSEventFactoryProtocol для создания объектов событий
 */
- (void)registerEventFactoryClass:(Class)factoryClass{
    
    eventFactory = [factoryClass new];
}


#pragma mark - DSStreamingEventProductorProtocol IMP (Private)

/**
    @abstract Метод, выполняющий производство событий (диспетчеризацию по конкретным методам)
    @discussion
    Выполняет диспетчеризацию в соответствующий метод (если объект журнала - в метод создания события из хурнала, и т.д.)
 
    @note
    Проверяет наличие фабрики, и соответствующего типа объекта
    
    @note
    Является приватным, т.к. не каждый Reporter с event-ами должен быть пригоден для использования вместе со стримером (но на основе его производятся события во всех производных классах)
 
    @param convertibleObject        Объект, из которого можно сгенерировать событие
    @return Готовый объект, реализующий интерфейс события
 */
- (id<DSStreamingEventProtocol>)produceStreamingEventWithObject:(id<DSEventConvertibleEntity>)convertibleObject{
    
    NSAssert(eventFactory, @"Event Factory is Undefined! Need call %@ method when init Reporter. Responder %@ in %s", NSStringFromSelector(@selector(registerEventFactoryClass:)), NSStringFromClass([self class]), __PRETTY_FUNCTION__);
    
    BOOL isJournalObject = [convertibleObject isKindOfClass:[DSJournal class]];
    BOOL isServiceObject = [convertibleObject isKindOfClass:[DSBaseLoggedService class]];
    
    BOOL isKnownObject = isJournalObject || isServiceObject;
    NSAssert(isKnownObject, @"Object for %@ class not supported with event creation in %@ in %s", NSStringFromClass([convertibleObject class]), NSStringFromClass([self class]), __PRETTY_FUNCTION__);
    
    if(isKnownObject){
        
        id <DSStreamingEventProtocol> newStreamingEvent = nil;
        if(isJournalObject){
            
            DSJournal *workJournal = (DSJournal*)convertibleObject;
            newStreamingEvent = [self eventForJournal:workJournal];
        }else if(isServiceObject){
            
            DSBaseLoggedService *workService = (DSBaseLoggedService*)convertibleObject;
            newStreamingEvent = [self eventForService:workService];
        }
        
        return newStreamingEvent;
    }
    return nil;
}


#pragma mark - DSReporterEventRecievingProtocol IMP

/// Создание события отправки из объекта журнала
- (id<DSStreamingEventProtocol>)eventForJournal:(DSJournal*)workJournal{
    
    id<DSStreamingEventProtocol> streamingEvent = [eventFactory eventForJournal:workJournal withDataMapping:self.mappingType];
    return streamingEvent;
}

/// Создание события отправки из объекта сервиса
- (id<DSStreamingEventProtocol>)eventForService:(DSBaseLoggedService*)workService{
    
    id<DSStreamingEventProtocol> streamingEvent = [eventFactory eventForService:workService withDataMapping:self.mappingType];
    return streamingEvent;
}

- (id<DSStreamingEventProtocol>)eventForRecords:(NSArray<DSJournalRecord*>*)workRecords withParentEntity:(id<DSEventConvertibleEntity>)parentEntity{
    
    id<DSStreamingEventProtocol> streamingEvent = [eventFactory eventForRecords:workRecords withParentEntity:parentEntity withDataMapping:self.mappingType];
    return streamingEvent;
}


@end

