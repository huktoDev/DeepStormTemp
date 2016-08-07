////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/**
 *      DSBasePeriodicStreamer.m
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

#import "DSBasePeriodicStreamer.h"
#import "DSStreamingComplexEvent.h"


@interface DSBasePeriodicStreamer ()

@property (strong, nonatomic, readwrite) NSTimer *streamingTimer;

@end


@implementation DSBasePeriodicStreamer{
    BOOL _isStreamingIntervalAssigned;
}

@synthesize streamingEventInterval=_streamingEventInterval;
@synthesize eventExecutor = _eventExecutor;
@synthesize eventProducer = _eventProducer;
@synthesize streamingEntitiesArray = _streamingEntitiesArray;


#pragma mark - Construction

+ (instancetype)streamerWithInterval:(NSTimeInterval)eventInterval{
    
    DSBasePeriodicStreamer *periodicStreamer = [DSBasePeriodicStreamer new];
    [periodicStreamer setStreamingEventInterval:eventInterval];
    
    return periodicStreamer;
}


#pragma mark - DSBaseControlStateStreamingInterface IMP

- (void)startStreaming{
    
    NSAssert(_isStreamingIntervalAssigned, @"Streaming Interval is usassigned!!! Before startStreaming need to assign this interval, responder class %@ in %s", NSStringFromClass([self class]), __PRETTY_FUNCTION__);
    NSAssert((self.streamingTimer == nil), @"Streaming Timer can be nil before start new Streaming, responder class %@ in %s", NSStringFromClass([self class]), __PRETTY_FUNCTION__);
    NSAssert((self.streamingEntitiesArray.count > 0), @"When we start streaming in %@ - we can add yet one Streaming object with %@ IMP to streamingEntitiesArray, call method : %s", NSStringFromClass([self class]), NSStringFromProtocol(@protocol(DSEventConvertibleEntity)), __PRETTY_FUNCTION__);
    
    if(self.streamingTimer){
        [self stopStreaming];
    }
    
    self.streamingTimer = [NSTimer scheduledTimerWithTimeInterval:self.streamingEventInterval target:self selector:@selector(newStreamingTick:) userInfo:nil repeats:YES];
}

- (void)stopStreaming{
    
    NSAssert((self.streamingTimer != nil), @"Streaming Timer can be not nil before stop Streaming, responder class %@ in %s", NSStringFromClass([self class]), __PRETTY_FUNCTION__);
    
    if(self.streamingTimer){
        if([self.streamingTimer isValid]){
            [self.streamingTimer invalidate];
        }
        self.streamingTimer = nil;
    }
}


#pragma mark - SET Timing

- (void)setStreamingEventInterval:(NSTimeInterval)streamingEventInterval{
    
    BOOL isValidStreamingInterval = (streamingEventInterval > 0.01f);
    NSAssert(isValidStreamingInterval, @"Streaming Interval %.4f in %s in %@ is incorrect", streamingEventInterval, __PRETTY_FUNCTION__, NSStringFromClass([self class]));
    
    _streamingEventInterval = streamingEventInterval;
    _isStreamingIntervalAssigned = YES;
}


#pragma mark - STREAMING Timer Tick

- (void)newStreamingTick:(NSTimer*)streamingTImer{
    
    // Здесь есть 3 варианта :
    // 1. По приоритету, если есть внутренний репортер - он создает событие
    // 2. Если есть другой производитель событий - создает он
    // 3. Если нету специального назначенного объекта - попытаться использовать собственный метод
    
    // !!!: Событие создает eventProducer или подкласс
    // !!!: Обрабатывает событие reporter или подкласс
    
    NSArray <id<DSStreamingEventProtocol>> *collectedStreamingEvents = [self _privateCollectStreamEventsArray];
    
    // Мы собрали n событий из x объектов
    
    NSUInteger countSuccessStartExecution = 0;
    for (id<DSStreamingEventProtocol> currentStreamEvent in collectedStreamingEvents) {
        
        BOOL isSearchAppropriateExecutor = [self _privateDispatchStreamEvent:currentStreamEvent];
        if(isSearchAppropriateExecutor){
            countSuccessStartExecution ++;
        }
    }
    
    // Запустилось k событий из y
    
    NSLog(@"FUCKING STREAMING TICK with EVENTs %@", collectedStreamingEvents);
}

- (NSArray<id<DSStreamingEventProtocol>>*)_privateCollectStreamEventsArray{
    
    NSMutableArray <id<DSStreamingEventProtocol>> *collectedStreamingEvents = [NSMutableArray new];
    for (id<DSEventConvertibleEntity> currentStreamingEntity in self.streamingEntitiesArray) {
        
        id<DSStreamingEventProtocol> newStreamingEvent = [self _privateDispatchBuildStreamingEventWithObject:currentStreamingEntity];
        if(newStreamingEvent){
            [collectedStreamingEvents addObject:newStreamingEvent];
        }
    }
    
    BOOL canUnionEvents = NO;
    SEL unionEventsSelector = @selector(canUnionAllStreamingEvents);
    if(self.eventProducer){
        
        BOOL isUnionMethodImplemented = [self.eventProducer respondsToSelector:unionEventsSelector];
        if(isUnionMethodImplemented){
            canUnionEvents = [self.eventProducer canUnionAllStreamingEvents];
        }
    }
    
    if(! canUnionEvents){
        canUnionEvents = [self canUnionAllStreamingEvents];
    }
    
    if(canUnionEvents){
        // Создать одно комплексное событие
        
        DSStreamingComplexEvent *bigComplexEvent = [DSStreamingComplexEvent eventWithSingeEventsArray:collectedStreamingEvents];
        return @[bigComplexEvent];
        
    }else{
        return [NSArray arrayWithArray:collectedStreamingEvents];
    }
}


#pragma mark - PRIVATE DISPATCH Methods (Select type of usage)

- (BOOL)_privateDispatchStreamEvent:(id<DSStreamingEventProtocol>)newStreamEvent{
    
    if(self.eventExecutor){
        
        SEL executionEventSelector = @selector(executeStreamingEvent:);
        BOOL isReporterStreamingImplemented = [self.eventExecutor respondsToSelector:executionEventSelector];
        NSAssert(isReporterStreamingImplemented, @"If we have inner executeReporter in %@, we can implement to %@ INTERFACE FOR STREAMING : %@. Exception generated in %s", NSStringFromClass([self class]), NSStringFromClass([self.eventExecutor class]), NSStringFromProtocol(@protocol(DSStreamingEventExecutorProtocol)), __PRETTY_FUNCTION__);
        
        if(isReporterStreamingImplemented){
            BOOL isEventStartExecuting = [self.eventExecutor executeStreamingEvent:newStreamEvent];
            if(isEventStartExecuting){
                return YES;
            }
        }
    }
    
    BOOL isEventExecutingStartInSubclass = [self executeStreamingEvent:newStreamEvent];
    if(isEventExecutingStartInSubclass){
        return YES;
    }
    
    return NO;
}

- (id<DSStreamingEventProtocol>)_privateDispatchBuildStreamingEventWithObject:(id<DSEventConvertibleEntity>)convertibleEntity{
    
    id<DSStreamingEventProtocol> newStreamingEvent = nil;
    SEL produceEventSelector = @selector(produceStreamingEventWithObject:);
    
    if(self.eventProducer){
        
        BOOL isProducerStreamingImplemented = [self.eventProducer respondsToSelector:produceEventSelector];
        NSAssert(isProducerStreamingImplemented, @"If we have speical eventProducer in %@, we can implement to %@ INTERFACE FOR STREAMING : %@. Exception generated in %s", NSStringFromClass([self class]), NSStringFromClass([self.eventProducer class]), NSStringFromProtocol(@protocol(DSStreamingEventProductorProtocol)), __PRETTY_FUNCTION__);
        
        if(isProducerStreamingImplemented){
            newStreamingEvent = [self.eventProducer produceStreamingEventWithObject:convertibleEntity];
        }
    }
    if(! newStreamingEvent){
        newStreamingEvent = [self produceStreamingEventWithObject:convertibleEntity];
    }
    return newStreamingEvent;
}


#pragma mark - METHODs FOR Subclassing (DSStreamingEventFullProtocol)

- (BOOL)executeStreamingEvent:(id<DSStreamingEventProtocol>)streamingEvent{
    
    return NO;
}

- (id<DSStreamingEventProtocol>)produceStreamingEventWithObject:(id<DSEventConvertibleEntity>)convertibleObject{
    return nil;
}

- (void)addStreamingEntity:(id<DSEventConvertibleEntity>)newEntity{
    
    if(! _streamingEntitiesArray){
        _streamingEntitiesArray = [NSMutableArray new];
    }
    [_streamingEntitiesArray addObject:newEntity];
}

- (BOOL)canUnionAllStreamingEvents{
    return NO;
}


@end
