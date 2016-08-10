////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/**
 *      DSBaseEmailReporter.m
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

#import "DSBaseEmailReporter.h"

#import "DSJournal.h"
#import "DSBaseLoggedService.h"
#import "DSFileReporter.h"
#import "NSString+DSEmailValidation.h"

#import "DSEmailEventFactory.h"
#import "DSStreamingEmailEvent.h"
#import "DSStreamingComplexEvent.h"

#import "DSEventSupportedProxyReporter.h"

@interface DSBaseEmailReporter () <DSStreamingEventExecutorProtocol>
@end

@implementation DSBaseEmailReporter{
    
    NSString *destinationAddress;
    NSMutableArray <DSStreamingEmailEvent*> *_temporaryEmailEvents;
}

@synthesize reportingCompletion = _reportingCompletion;

+ (DSBaseEmailReporter<DSStreamingEventFullProtocol>*)extendedEmailReporter{
    DSBaseEmailReporter<DSStreamingEventFullProtocol> *extendedReporter = [[self class] new];
    return extendedReporter;
}

/// Задает фабрику событий отправки имейлов
- (instancetype)init{
    
    if(self = [super init]){
        [self registerEventFactoryClass:[DSEmailEventFactory class]];
    }
    DSBaseEventBuiltInReporter<DSStreamingEventFullProtocol> *proxyReporter = [DSEventSupportedProxyReporter proxyReporterForEventReporter:self];
    return (DSBaseEmailReporter*)proxyReporter;
}


#pragma mark - DSEmailReporterProtocol (SENDING Email)

/**
    @abstract Установить Email-назначения
    @discussion
    Устанавливает имейл, на которыйбудет репортер  отправлять репорт. На самом деле так как то не автоматический отправитель - устанавливает это значение в Recepients MFMailComposeViewController
 
    @note Проверяет валидность переданного имейла
 
    @param destinationEmail      Имейл назначения (куда отправлять репорт)
 */
- (void)addDestinationEmail:(NSString*)destinationEmail{
    
    BOOL isValidEmail = [destinationEmail isValidEmail];
    NSAssert(isValidEmail, @"Destination Email is not valid in %@", NSStringFromClass([self class]));
    
    destinationAddress = [destinationEmail copy];
}

/// Геттер для имейла назначения
- (NSString*)getDestinationEmail{
    
    return [destinationAddress copy];
}

/**
    @abstract Метод отправки имейла с прикрепленным файлом
    @discussion
    Является враппером над методом отсылки для множественных прикрепленных файлов.
 
    @see
    sendEmailWithFileArray:
 
    @param emailData       Данные файла для отправки
    @param fileName       Как именовать файл с данными
 */
- (void)sendEmailWithData:(NSData*)emailData withFilename:(NSString*)fileName{
    
    NSAssert(emailData, @"FILE DATA Must be not nil");
    NSAssert(fileName, @"FILE NAME Must be not nil");
    
    [self sendEmailWithFileArray:@{fileName : emailData}];
}


#pragma mark - MAIN SENDing method (For SUBCLASS)

// Заглушка для переопределения (основной метод, который должен реализовывать дочерний репортер)
- (void)sendEmailWithFileArray:(NSDictionary <NSString*, NSData*> *)filesDictionary{
    
    NSString *stubDescription = [NSString stringWithFormat:@"Method %s don't need to implement in subclass of %@", __PRETTY_FUNCTION__, NSStringFromClass([DSBaseEmailReporter class])];
    @throw [NSException exceptionWithName:@"NoImplementationException" reason:stubDescription userInfo:nil];
}

#pragma mark - DSSimpleReporterProtocol

/**
    @abstract Метод отправки репорта журнала
    @discussion
    Собирает событие отправки имейла для журнала, и выполняет исполнение отправки
 
    @param reportingJournal      Журнал, который будет отправляться по имейлу
 */
- (void)sendReportJournal:(DSJournal *)reportingJournal{
    
    DSStreamingEmailEvent *emailEvent = [self eventForJournal:reportingJournal];
    [self executeStreamingEvent:emailEvent];
}

/**
    @abstract Метод отправки репорта сервиса
    @discussion
    Собирает событие отправки имейла для сервиса, и выполняет исполнение отправки
 
    @param reportingService      Сервис, который будет отправляться по имейлу
 */
- (void)sendReportService:(DSBaseLoggedService *)reportingService{
    
    DSStreamingEmailEvent *emailEvent = [self eventForService:reportingService];
    [self executeStreamingEvent:emailEvent];
}


#pragma mark - DSComplexReporterProtocol

/**
    @abstract Один из методов формирования комплексного  репорта
    @discussion
    Создает событие отправки имейла из журнала, и помещает во временный буфер (массив)
 
    @param reportingJournal      Журнал, данные которого следует прикрепить к репорту
 */
- (void)addPartReportJournal:(DSJournal*)reportingJournal{
    
    if(! _temporaryEmailEvents){
        _temporaryEmailEvents = [NSMutableArray new];
    }
    DSStreamingEmailEvent *newEmailEvent = [self eventForJournal:reportingJournal];
    [_temporaryEmailEvents addObject:newEmailEvent];
}

/**
    @abstract Один из методов формирования комплексного  репорта
    @discussion
    Создает событие отправки имейла из сервиса, и помещает во временный буфер (массив)
 
    @param reportingService      Сервис, данные которого следует прикрепить к репорту
 */
- (void)addPartReportService:(DSBaseLoggedService*)reportingService{
    
    if(! _temporaryEmailEvents){
        _temporaryEmailEvents = [NSMutableArray new];
    }
    DSStreamingEmailEvent *newEmailEvent = [self eventForService:reportingService];
    [_temporaryEmailEvents addObject:newEmailEvent];
}

/**
    @abstract  Метод отправки комплексного репорта
    @discussion
    Составляет из  всех частей комплексного репорта письмо и отправляет его.
    Делает это следующим образом : Создает комплексное событие отправки из простых событий в буфере.
    Исполняет комплексное событие отправки, и удаляет буфер
 */
- (void)performAllReports{
    
    DSStreamingComplexEvent *newComplexEmailEvent = [DSStreamingComplexEvent eventWithSingeEventsArray:_temporaryEmailEvents];
    [self executeStreamingEvent:newComplexEmailEvent];
    _temporaryEmailEvents = nil;
}


#pragma mark - DSStreamingEventExecutorProtocol IMP

/**
    @abstract Исполняет событий отправки имейла
    @discussion
    Есть 2 варианта  отправки имейла - комплексное событие, состоящие из мелких файлов, и простой одинарный файл.
    Выполняет диспетчеризацию в подходящий метод
 
    @param streamingEvent       Событие отправки, которое нужно исполнить (здесь можно обработать только события отправки имейла)
    @return YES - если отправка была начата
 */
- (BOOL)executeStreamingEvent:(id<DSStreamingEventProtocol>)streamingEvent{
    
    // Эвент может быть комплексным, или может быть простым
    BOOL isComplexEvent = [streamingEvent isKindOfClass:[DSStreamingComplexEvent class]];
    BOOL isSimpleEmailEvent = [streamingEvent isKindOfClass:[DSStreamingEmailEvent class]];
    
    if(isSimpleEmailEvent){
        
        // Если это простое событие отправки одного файла - получить данные, и выполнить отправку
        DSStreamingEmailEvent *emailEvent = (DSStreamingEmailEvent*)streamingEvent;
        
        BOOL isStartSimpleEmailSending = [self executeSimpleEmailEvent:emailEvent];
        return isStartSimpleEmailSending;
        
    }else if(isComplexEvent){
        
        // Если это комплексное событие отправки нескольких файлов - получить словарь с информацией обо всех файлах, выполнить отправку одним письмом
        DSStreamingComplexEvent *complexEmailEvent = (DSStreamingComplexEvent*)streamingEvent;
        
        BOOL isStartComplexEmailSending = [self executeComplexEmailEvent:complexEmailEvent];
        return isStartComplexEmailSending;
        
    }else{
        return NO;
    }
}

/// Может ли данный репортер объединять события отправки в одно комплексное?
- (BOOL)canUnionAllStreamingEvents{
    return YES;
}


#pragma mark - EMAIL EVENTS Executions

/// Исполняет простое событие отправки имейла (с одним файлом)
- (BOOL)executeSimpleEmailEvent:(DSStreamingEmailEvent*)emailEvent{
    
    NSData *emailData = emailEvent.emailData;
    NSString *attachmentFileName = emailEvent.attachmentFileName;
    
    [self sendEmailWithData:emailData withFilename:attachmentFileName];
    return YES;
}

/// Исполняет сложное событие отправки имейла (с несколькими файлами в одном письме)
- (BOOL)executeComplexEmailEvent:(DSStreamingComplexEvent*)emailEvent{
    
    // Обрабатывает только вложенные события отправки имейла
    NSMutableDictionary <NSString*, NSData*> *filesDictionary = [NSMutableDictionary new];
    for (id <DSStreamingEventProtocol> attachmentEvent in emailEvent.unionStreamingEvents) {
        
        BOOL isEmailAttachmentEvent = [attachmentEvent isKindOfClass:[DSStreamingEmailEvent class]];
        if(isEmailAttachmentEvent){
            
            DSStreamingEmailEvent *attachmentEmailEvent = (DSStreamingEmailEvent*)attachmentEvent;
            
            NSData *emailData = attachmentEmailEvent.emailData;
            NSString *attachmentFileName = attachmentEmailEvent.attachmentFileName;
            
            [filesDictionary setObject:emailData forKey:attachmentFileName];
        }
    }
    
    // Если хотя-бы одно событие было разобрано (есть хотя-бы один файл для отправки - отправить и вернуть YES)
    if(filesDictionary.count > 0){
        [self sendEmailWithFileArray:filesDictionary];
        return YES;
    }else{
        return NO;
    }
}


@end
