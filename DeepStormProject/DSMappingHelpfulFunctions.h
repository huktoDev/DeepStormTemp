////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/**
 *      DSMappingHelpfulFunctions.h
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

#ifndef DSMappingHelpfulFunctions_h
#define DSMappingHelpfulFunctions_h


#import "DSJournalMappingProtocol.h"

/**
    @def DS_FILE_EXTENSION_XML
        Расширение для XML-файла с логами
 */
/**
    @def DS_FILE_EXTENSION_JSON
        Расширение для JSON-файла с логами
 */

#define DS_FILE_EXTENSION_XML   @".xml"
#define DS_FILE_EXTENSION_JSON  @".json"

/**
    @function GetObjectMapperClassByMappingType
    @abstract Возвращает объект метакласса, ассоциируемого с данным типом маппинга
    @param mappingType      Тип маппинга DSJournalObjectMapping (например, JSON или XML)
    @return Метакласс для объекта маппера (из него можно произвести маппер)
 */
Class<DSJournalMappingProtocol> GetObjectMapperClassByMappingType(DSJournalObjectMapping mappingType);


/**
    @function GetFileExtensionForMapperType
    @abstract Возвращает расширение для файла с соответствующим типом маппинга
    @param mappingType      Тип маппинга DSJournalObjectMapping (например, JSON или XML)
    @return Строка-расширение для файла (включает точку) (@".xml", @".json")
 */
NSString* GetFileExtensionForMapperType(DSJournalObjectMapping mappingType);
    

#endif /* DSMappingHelpfulFunctions_h */
