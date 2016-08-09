//
//  DSLocalSQLDatabaseEventFactory.m
//  DeepStormProject
//
//  Created by Alexandr Babenko on 10.08.16.
//  Copyright © 2016 Alexandr Babenko. All rights reserved.
//

#import "DSLocalSQLDatabaseEventFactory.h"
#import "DSStreamingDatabaseEvent.h"

@implementation DSLocalSQLDatabaseEventFactory

- (DSStreamingEmailEvent*)eventForJournal:(DSJournal*)workJournal withDataMapping:(DSJournalObjectMapping)mappingType{
    
    DSStreamingDatabaseEvent *newDatabaseEvent = [DSStreamingDatabaseEvent new];
    newDatabaseEvent.streamingEntity = workJournal;
    
    return newDatabaseEvent;
}

- (DSStreamingEmailEvent*)eventForService:(DSBaseLoggedService*)workService withDataMapping:(DSJournalObjectMapping)mappingType{
    
    DSStreamingDatabaseEvent *newDatabaseEvent = [DSStreamingDatabaseEvent new];
    newDatabaseEvent.streamingEntity = workService;
    
    return newDatabaseEvent;
}


@end
