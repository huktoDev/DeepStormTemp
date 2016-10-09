//
//  DSAdaptedDBJournalRecord+Convertation.m
//  ReporterProject
//
//  Created by Alexandr Babenko on 22.07.16.
//  Copyright © 2016 Alexandr Babenko. All rights reserved.
//

#import "DSAdaptedDBJournalRecord+Convertation.h"
#import "DSJournalRecord.h"

@implementation DSAdaptedDBJournalRecord (Convertation)


+ (instancetype)adaptedModelForRecord:(DSJournalRecord*)convertingRecord fromBlankModel:(DSAdaptedDBJournalRecord*)blankAdaptedRecord{
    
    DSAdaptedDBJournalRecord *newAdaptedRecord = blankAdaptedRecord;
    
    newAdaptedRecord.number = convertingRecord.recordNumber;
    newAdaptedRecord.bodyText = convertingRecord.recordDescription;
    newAdaptedRecord.date = convertingRecord.recordDate;
    newAdaptedRecord.additionalInfo = convertingRecord.recordInfo;
    newAdaptedRecord.logLevel = @(convertingRecord.recordLogLevel);
    newAdaptedRecord.logLevelDescription = DSLogLevelDescription(convertingRecord.recordLogLevel);
    
    return newAdaptedRecord;
}


- (DSJournalRecord*)convertToJournalRecord{
    
    DSJournalRecord *newRecord = [DSJournalRecord new];
    
    newRecord.recordNumber = self.number;
    newRecord.recordDescription = self.bodyText;
    newRecord.recordDate = self.date;
    newRecord.recordInfo = self.additionalInfo;
    newRecord.recordLogLevel = [self.logLevel unsignedIntegerValue];
    
    return newRecord;
}


@end
