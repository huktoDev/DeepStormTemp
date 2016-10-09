////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/**
 *      DSEventSupportedEmailReporter.m
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

#import "DSEventSupportedProxyReporter.h"

@implementation DSEventSupportedProxyReporter{
    
    @private
    DSBaseEventBuiltInReporter<DSStreamingEventExecutorProtocol> *_proxiedEventReporter;
}

+ (DSBaseEventBuiltInReporter<DSStreamingEventFullProtocol>*)proxyReporterForEventReporter:(DSBaseEventBuiltInReporter<DSStreamingEventExecutorProtocol>*)eventReporter{
    
    DSBaseEventBuiltInReporter<DSStreamingEventFullProtocol> *proxyReporter = (DSBaseEventBuiltInReporter<DSStreamingEventFullProtocol>*)[[DSEventSupportedProxyReporter alloc] initWithEventReporter:eventReporter];
    return proxyReporter;
}

- (instancetype)initWithEventReporter:(DSBaseEventBuiltInReporter<DSStreamingEventExecutorProtocol>*)eventReporter{
    
     _proxiedEventReporter = eventReporter;
    return self;
}

#pragma mark - DSStreamingEventProductorProtocol

/**
    @abstract Производит транзакцию для репортера из сущности
    @discussion
    Если есть имплементация этого метода в проксируемом (заменяемом) репортере - передать управление методу проксируемого объекта
    @param convertibleObject        Объект, из которого будет производится транзакция
    @return Готовый объект транзакции (nil, если не удалось произвести)
 */
- (id<DSStreamingEventProtocol>)produceStreamingEventWithObject:(id<DSEventConvertibleEntity>)convertibleObject{
    
    SEL produceStreamEventSelector = @selector(produceStreamingEventWithObject:);
    
    IMP superImplementation = [_proxiedEventReporter methodForSelector:produceStreamEventSelector];
    if(superImplementation != NULL){
        
        id<DSStreamingEventProtocol> (*produceFuncSignature)(id, SEL, id<DSEventConvertibleEntity>) = (void *)superImplementation;
        return produceFuncSignature(self, produceStreamEventSelector, convertibleObject);
    }else{
        return nil;
    }
}

/**
    @abstract Позволено ли объединять примитивные транзакции в комплексные
    @discussion
    Если есть имплементация этого метода в проксируемом (заменяемом) репортере - передать управление методу проксируемого объекта
    @return Можно ли объединять транзакции? Если да - формирует одну большую транзакцию, иначе - массив простых транзакций
 */
- (BOOL)canUnionAllStreamingEvents{
    
    SEL unionStreamEventSelector = @selector(canUnionAllStreamingEvents);
    
    IMP superImplementation = [_proxiedEventReporter methodForSelector:unionStreamEventSelector];
    if(superImplementation != NULL){
        
        BOOL (*unionFuncSignature)(id, SEL) = (void *)superImplementation;
        return unionFuncSignature(self, unionStreamEventSelector);
    }else{
        return NO;
    }
}


#pragma mark - DSStreamingEventExecutorProtocol

/**
    @abstract Метод, выполнящий транзакцию
    @discussion
    Если есть имплементация этого метода в проксируемом (заменяемом) репортере - передать управление методу проксируемого объекта
    @param streamingEvent          Транзакция к исполнению
    @return Удалось ли выполнить/начать выполнение транзакции?
 */
- (BOOL)executeStreamingEvent:(id<DSStreamingEventProtocol>)streamingEvent{
    
    SEL executeStreamEventSelector = @selector(executeStreamingEvent:);
    
    IMP superImplementation = [_proxiedEventReporter methodForSelector:executeStreamEventSelector];
    if(superImplementation != NULL){
        
        BOOL (*executeFuncSignature)(id, SEL, id<DSStreamingEventProtocol>) = (void *)superImplementation;
        return executeFuncSignature(self, executeStreamEventSelector, streamingEvent);
    }else{
        return NO;
    }
}


#pragma mark - Forwarding Methods

- (id)forwardingTargetForSelector:(SEL)aSelector{
    return _proxiedEventReporter;
}

- (BOOL)respondsToSelector:(SEL)aSelector{
    
    BOOL isProxiedObjectCanRespond = [_proxiedEventReporter respondsToSelector:aSelector];
    return isProxiedObjectCanRespond;
}

@end
