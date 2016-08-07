////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/**
 *      DSFileEventFactory.m
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

#import "DSFileEventFactory.h"

#import "DSStreamingFileEvent.h"
#import "DSJournal.h"
#import "DSBaseLoggedService.h"

@implementation DSFileEventFactory


- (NSString*)fileNameForConvertibeEntity:(id<DSEventConvertibleEntity>)convertibleObject withMappingType:(DSJournalObjectMapping)mappingType{
    
    BOOL isJournalObject = [convertibleObject isKindOfClass:[DSJournal class]];
    BOOL isServiceObject = [convertibleObject isKindOfClass:[DSBaseLoggedService class]];
    
    BOOL isKnownObject = isJournalObject || isServiceObject;
    NSAssert(isKnownObject, @"Object for %@ class not supported with event creation in %@ in %s", NSStringFromClass([convertibleObject class]), NSStringFromClass([self class]), __PRETTY_FUNCTION__);
    
    if(isKnownObject){
        
        NSString *convertibleEntityFileName = nil;
        if(isJournalObject){
            
            DSJournal *workJournal = (DSJournal*)convertibleObject;
            convertibleEntityFileName = [self fileNameForJournal:workJournal withMappingType:mappingType];
        }else if(isServiceObject){
            
            DSBaseLoggedService *workService = (DSBaseLoggedService*)convertibleObject;
            convertibleEntityFileName = [self fileNameForService:workService withMappingType:mappingType];
        }
        
        return convertibleEntityFileName;
    }
    return nil;
}

- (NSString*)fileNameForJournal:(DSJournal*)workJournal withMappingType:(DSJournalObjectMapping)mappingType{
    
    NSString *fileExtension = GetFileExtensionForMapperType(mappingType);
    
    // Сформировать путь к результирующему файлу
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *currentJournalName = workJournal.journalName;
    if(currentJournalName){
        
        // Добавить расширение к имени журнала
        currentJournalName = [currentJournalName stringByAppendingString:fileExtension];
    }
    
    // Если у журнала нет имени - задать журналу специальное имя
    if(! currentJournalName){
        
        NSString *unknownJournalName;
        BOOL defineJournalName = NO;
        for (NSUInteger indexUndefinedJournal = 1; indexUndefinedJournal <= 100; indexUndefinedJournal ++) {
            
            unknownJournalName = [NSString stringWithFormat:@"unknownJournal%lu%@", (unsigned long)indexUndefinedJournal, fileExtension];
            NSString *pathToUnknownJournal = [documentsDirectory stringByAppendingPathComponent:unknownJournalName];
            
            BOOL unknownJournalExist = [[NSFileManager defaultManager] fileExistsAtPath:pathToUnknownJournal];
            if(! unknownJournalExist){
                defineJournalName = YES;
                break;
            }
        }
        
        if(defineJournalName){
            currentJournalName = unknownJournalName;
        }
    }
    return currentJournalName;
}

- (NSString*)fileNameForService:(DSBaseLoggedService*)workService withMappingType:(DSJournalObjectMapping)mappingType{
    
    NSString *currentJournalName = workService.logJournal.journalName;
    
    // Добавить расширение к имени журнала
    NSString *fileExtension = GetFileExtensionForMapperType(mappingType);
    currentJournalName = [currentJournalName stringByAppendingString:fileExtension];
    
    return currentJournalName;
}


- (DSStreamingFileEvent*)eventForJournal:(DSJournal*)workJournal withDataMapping:(DSJournalObjectMapping)mappingType{
    
    // Получить данные журнала
    Class <DSJournalMappingProtocol> objectMapperClass = GetObjectMapperClassByMappingType(mappingType);
    NSData *journalData = [objectMapperClass dataRepresentationForJournal:workJournal];
    
    NSString *fileJournalName = [self fileNameForJournal:workJournal withMappingType:mappingType];
    
    DSStreamingFileEvent *newJournalSendingEvent = [DSStreamingFileEvent new];
    
    newJournalSendingEvent.fileName = fileJournalName;
    newJournalSendingEvent.fileData = journalData;
    
    return newJournalSendingEvent;
}

- (DSStreamingFileEvent*)eventForService:(DSBaseLoggedService*)workService withDataMapping:(DSJournalObjectMapping)mappingType{
    
    // Получить данные сервиса
    Class <DSJournalMappingProtocol> objectMapperClass = GetObjectMapperClassByMappingType(mappingType);
    NSData *serviceData = [objectMapperClass dataRepresentationForService:workService];
    
    NSString *fileJournalName = [self fileNameForService:workService withMappingType:mappingType];
    
    DSStreamingFileEvent *newServiceSendingEvent = [DSStreamingFileEvent new];
    
    newServiceSendingEvent.fileName = fileJournalName;
    newServiceSendingEvent.fileData = serviceData;
    
    return newServiceSendingEvent;
}

- (id<DSStreamingEventProtocol>)eventForRecords:(NSArray<DSJournalRecord*>*)workRecords withParentEntity:(id<DSEventConvertibleEntity>)parentObject withDataMapping:(DSJournalObjectMapping)mappingType{
    
    Class <DSJournalMappingProtocol> objectMapperClass = GetObjectMapperClassByMappingType(mappingType);
    NSData *recordsData = [objectMapperClass dataRepresentationForRecords:workRecords];
    
    NSString *parentFileName = [self fileNameForConvertibeEntity:parentObject withMappingType:mappingType];
    
    DSStreamingFileEvent *newIncrementalSendingEvent = [DSStreamingFileEvent new];
    
    newIncrementalSendingEvent.fileName = parentFileName;
    newIncrementalSendingEvent.fileData = recordsData;
    
    return newIncrementalSendingEvent;
}

@end
