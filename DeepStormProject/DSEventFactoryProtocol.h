////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/**
 *      DSEventFactoryProtocol.h
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

#import "DSJournalMappingProtocol.h"
#import "DSSendingEventInterfaces.h"

@class DSJournal, DSBaseLoggedService, DSJournalRecord;
@class DSStreamingFileEvent;

/**
    @protocol DSEventFactoryProtocol
    @author HuktoDev
    @updated 21.06.2016
    @abstract Протокол, который обязана реализовывать фабрика событий (будет дополняться и изменяться по идее)
 */
@protocol DSEventFactoryProtocol <NSObject>

- (id<DSStreamingEventProtocol>)eventForJournal:(DSJournal*)workJournal withDataMapping:(DSJournalObjectMapping)mappingType;

- (id<DSStreamingEventProtocol>)eventForService:(DSBaseLoggedService*)workService withDataMapping:(DSJournalObjectMapping)mappingType;

- (id<DSStreamingEventProtocol>)eventForRecords:(NSArray<DSJournalRecord*>*)workRecords withParentEntity:(id<DSEventConvertibleEntity>)parentObject withDataMapping:(DSJournalObjectMapping)mappingType;

@end
