////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/**
 *      DSMappingHelpfulFunctions.m
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
#import "DSMappingHelpfulFunctions.h"

#import "DSJournalXMLMapper.h"
#import "DSJournalJSONMapper.h"

Class<DSJournalMappingProtocol> GetObjectMapperClassByMappingType(DSJournalObjectMapping mappingType){
    
    // Проверить, чтобы тип лежал в подходящем диапазоне
    if(mappingType < DSJournalObjectXMLMapping && mappingType > DSJournalObjectJSONMapping){
        
        @throw [NSException exceptionWithName:@"unknownMappingException" reason:@"mapping type DSJournalObjectMapping is not recognized" userInfo:nil];
    }
    
    // Вернуть соответствующий объект метакласса маппера
    switch (mappingType) {
        case DSJournalObjectXMLMapping:
            return [DSJournalXMLMapper class];
        case DSJournalObjectJSONMapping:
            return [DSJournalJSONMapper class];
        default:
            break;
    }
    return nil;
}

NSString* GetFileExtensionForMapperType(DSJournalObjectMapping mappingType){
    
    switch (mappingType) {
        case DSJournalObjectXMLMapping:
            return DS_FILE_EXTENSION_XML;
        case DSJournalObjectJSONMapping:
            return DS_FILE_EXTENSION_JSON;
        default:
            @throw [NSException exceptionWithName:@"unknownMappingType" reason:@"reportFileExtension is undefined" userInfo:nil];
    }
}

