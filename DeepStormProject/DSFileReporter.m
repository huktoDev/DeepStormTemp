////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/**
 *      DSFileRepoter.m
 *      DeepStorm Framework
 *
 *      Created by Alexandr Babenko on 27.02.16.
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

#import "DSFileReporter.h"
#import "DSJournal.h"
#import "DSBaseLoggedService.h"

#import "DSFileEventFactory.h"
#import "DSStreamingFileEvent.h"


@implementation DSFileReporter

@synthesize fileDataArray;

#pragma mark - Intitialization

/// Назначает фабрику событий
- (instancetype)init{
    if(self = [super init]){
        
        fileDataArray = [NSMutableDictionary new];
        [self registerEventFactoryClass:[DSFileEventFactory class]];
    }
    return self;
}

#pragma mark - Construction

/**
    @abstract Конструктор репортера с типом маппинга
    @discussion
    Публичный статический метод для получения репортера
    
    @throw unknownMappingException
        Если тип маппинга нераспознан, или расширение не определено
 
    @param mappingType      тип маппинга
    @return Готовый объект DSFileReporter-а
 */
+ (instancetype)fileReporterWithMappingType:(DSJournalObjectMapping)mappingType{
    
    DSFileReporter *fileReporter = [[DSFileReporter alloc] initWithMappingType:mappingType];
    return fileReporter;
}


#pragma mark - DSSimpleReporterProtocol IMP

/**
    @abstract Отсылает репорт для определенного журнала
    @discussion
 
    @note Последовательность выполнения :
    <ol type="1">
        <li> Получает специальное событие отправки из объекта журнала </li>
        <li> Исполняет это событие </li>
    </ol>
 
    @param reportingJournal      Журнал, для которого нужно отправить репорт
 */
- (void)sendReportJournal:(DSJournal *)reportingJournal{
    
    DSStreamingFileEvent *journalSendingEvent = [self eventForJournal:reportingJournal];
    [self executeStreamingEvent:journalSendingEvent];
}


/**
    @abstract Отсылает репорт для определенного сервиса
    @discussion
 
    @note Последовательность выполнения :
    <ol type="1">
        <li> Получает специальное событие отправки из объекта сервиса </li>
        <li> Исполняет это событие </li>
    </ol>
 
    @param reportingService      Сервис, для которого нужно отправить репорт
 */
- (void)sendReportService:(DSBaseLoggedService *)reportingService{
    
    DSStreamingFileEvent *serviceSendingEvent = [self eventForService:reportingService];
    [self executeStreamingEvent:serviceSendingEvent];
}


#pragma mark - DSStreamingEventExecutorProtocol IMP

/**
    @abstract Исполняет событие отправки файла в файловую систему
    @discussion
    Проверяет, чтобы событие  являлось определенного класса (DSStreamingFileEvent), и чтобы название файла не  было  nil
    Просто записывает данные в файл.
 
    @param streamingEvent       Событие, которое нужно исполнить (данным репортером поддерживаются только события отправки в файл)
    @return Если отправка в файл невозможна - NO. Если началась отправка - YES
 */
- (BOOL)executeStreamingEvent:(id<DSStreamingEventProtocol>)streamingEvent{
    
    BOOL isSingleStreamingFileEvent = [streamingEvent isKindOfClass:[DSStreamingFileEvent class]];
    if(isSingleStreamingFileEvent){
        
        DSStreamingFileEvent *singleStreamingEvent = (DSStreamingFileEvent*)streamingEvent;
        
        NSData *streamingData = singleStreamingEvent.fileData;
        NSString *streamingJournalName = singleStreamingEvent.fileName;
        
        if(! streamingJournalName){
            return NO;
        }
        
        // Сформировать путь к результирующему файлу
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        
        [fileDataArray setObject:streamingData forKey:streamingJournalName];
        NSString *currentStreamingFile = [documentsDirectory stringByAppendingPathComponent:streamingJournalName];
        
        // Записать данные в файл
        [self sendData:streamingData toFile:currentStreamingFile];
        return YES;
    }else{
        return NO;
    }
}


#pragma mark - DSStreamingEventProductorProtocol IMP

/// Метод-мост между закрытым интерфейсом суперкласса и открытым интерфейсом DSFileReporter
- (id<DSStreamingEventProtocol>)produceStreamingEventWithObject:(id<DSEventConvertibleEntity>)convertibleObject{
    
    SEL produceStreamEventSelector = @selector(produceStreamingEventWithObject:);
    
    IMP superImplementation = [[[DSFileReporter superclass] new] methodForSelector:produceStreamEventSelector];
    if(superImplementation != NULL){
        
        id<DSStreamingEventProtocol> (*produceFuncSignature)(id, SEL, id<DSEventConvertibleEntity>) = (void *)superImplementation;
        return produceFuncSignature(self, produceStreamEventSelector, convertibleObject);
    }else{
        return nil;
    }
}


/**
    @abstract Записывает данные в файл
    @discussion
    Сначала проверяет, существует ли схожий файл, и удаляет его, если таковой уже существует.
    После чего просто атомарно пишет данные в файл
 
    @param preparedData         Данные, которые  будут в файле
    @param filePath         Путь, по которому будет создан файл в файловой системе
 */
- (void)sendData:(NSData*)preparedData toFile:(NSString*)filePath{
    
    // Удалить файл, если он уже существует
    if([[NSFileManager defaultManager] fileExistsAtPath:filePath]){
        NSError *deletingError = nil;
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:&deletingError];
        if(deletingError){
            NSLog(@"Delete File Error %@", [deletingError localizedDescription]);
            return;
        }
    }
    
    // Создать файл, и записать в него данные
    [preparedData writeToFile:filePath atomically:YES];
}


/**
    @abstract Метод удаления файлов, записанных репортером
    @discussion
    Репортеру нужно иметь возможность обратного создания файлу действия (в данном случае - удаления). Кроме того, т.к. DSFileReporter используется в других репортерах, как вспомогательный (данные хранятся в качестве буфера). Позволяет "подтереть" эти временные файлы после  использования.
 
    @throw fileDeletingException
        Исключение при ошибке удаления файла
 */
- (void)removeDataFiles{
    
    BOOL wasFilesSaved = (self.fileDataArray.count != 0);
    NSAssert(wasFilesSaved, @"Try removing Files before Saving");
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    for (NSString *fileName in [self.fileDataArray allKeys]) {
        
        NSString *fileResultPath = [documentsDirectory stringByAppendingPathComponent:fileName];
        BOOL isFileExists = [[NSFileManager defaultManager] fileExistsAtPath:fileResultPath];
        NSAssert(isFileExists, @"File for Removing is not exist !!!");
        
        NSError *deletingError = nil;
        BOOL isFileDeleted = [[NSFileManager defaultManager] removeItemAtPath:fileResultPath error:&deletingError];
        if(! isFileDeleted || deletingError){
            
            NSString *deletingExceptionReason = [NSString stringWithFormat:@"File Deleting Error : %@", [deletingError localizedDescription]];
            @throw [NSException exceptionWithName:@"fileDeletingException" reason:deletingExceptionReason userInfo:nil];
        }
    }
    [self.fileDataArray removeAllObjects];
}


@end
