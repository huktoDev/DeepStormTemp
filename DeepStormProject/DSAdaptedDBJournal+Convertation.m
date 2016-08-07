//
//  DSAdaptedDBJournal+Convertation.m
//  ReporterProject
//
//  Created by Alexandr Babenko on 22.07.16.
//  Copyright © 2016 Alexandr Babenko. All rights reserved.
//

#import "DSAdaptedDBJournal+Convertation.h"
#import "DSJournal.h"

#import "DSAdaptedObjectsFactory.h"
#import "DSAdaptedDBJournalRecord.h"

@implementation DSAdaptedDBJournal (Convertation)

+ (instancetype)adaptedModelForJournal:(DSJournal*)convertingJournal fromBlankModel:(DSAdaptedDBJournal*)blankAdaptedJournal andModelsFactory:(DSAdaptedObjectsFactory*)modelsFactory{
    
    DSAdaptedDBJournal *newAdaptedJournal = blankAdaptedJournal;
    
    newAdaptedJournal.journalName = convertingJournal.journalName;
    newAdaptedJournal.journalClass = NSStringFromClass([convertingJournal class]);
    newAdaptedJournal.currentCount = @(convertingJournal.countRecords);
    newAdaptedJournal.maxCount = @(convertingJournal.maxCountStoredRecords);
    newAdaptedJournal.outputStreamingState = @( ! convertingJournal.outputLoggingDisabled);
    
    NSMutableSet *childRecords = [NSMutableSet new];
    [convertingJournal enumerateRecords:^(DSJournalRecord *nextRecord) {
        
        DSAdaptedDBJournalRecord *newChildAdaptedRecord = [modelsFactory adaptedModelFromRecord:nextRecord];
        if(newChildAdaptedRecord){
            [childRecords addObject:newChildAdaptedRecord];
        }
    }];
    if(childRecords.count > 0){
        newAdaptedJournal.childRecords = childRecords;
    }
    
    return newAdaptedJournal;
}

- (DSJournal*)convertToJournal{
    
    DSJournal *newJournal = [NSClassFromString(self.journalClass) new];
    
    newJournal.journalName = self.journalName;
    newJournal.maxCountStoredRecords = [self.maxCount unsignedIntegerValue];
    newJournal.outputLoggingDisabled = ! [self.outputStreamingState unsignedIntegerValue];
    
    return newJournal;
}

@end
