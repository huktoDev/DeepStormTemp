////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/**
 *      DSEmailEventFactory.m
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

#import "DSEmailEventFactory.h"

#import "DSStreamingEmailEvent.h"
#import "DSJournal.h"
#import "DSBaseLoggedService.h"

#import "DSFileEventFactory.h"
#import "DSStreamingFileEvent.h"

@implementation DSEmailEventFactory


#pragma mark - DSEventFactoryProtocol IMP


- (DSStreamingEmailEvent*)eventForJournal:(DSJournal*)workJournal withDataMapping:(DSJournalObjectMapping)mappingType{
    
    DSFileEventFactory *fileEventFactory = [DSFileEventFactory new];
    DSStreamingFileEvent *fileHelpfulEvent = [fileEventFactory eventForJournal:workJournal withDataMapping:mappingType];
    
    DSStreamingEmailEvent *newEmailEvent = [DSStreamingEmailEvent new];
    
    newEmailEvent.emailData = fileHelpfulEvent.fileData;
    newEmailEvent.attachmentFileName = fileHelpfulEvent.fileName;
    
    return newEmailEvent;
}

- (DSStreamingEmailEvent*)eventForService:(DSBaseLoggedService*)workService withDataMapping:(DSJournalObjectMapping)mappingType{
    
    DSFileEventFactory *fileEventFactory = [DSFileEventFactory new];
    DSStreamingFileEvent *fileHelpfulEvent = [fileEventFactory eventForService:workService withDataMapping:mappingType];
    
    DSStreamingEmailEvent *newEmailEvent = [DSStreamingEmailEvent new];
    
    newEmailEvent.emailData = fileHelpfulEvent.fileData;
    newEmailEvent.attachmentFileName = fileHelpfulEvent.fileName;
    
    return newEmailEvent;
}

@end
