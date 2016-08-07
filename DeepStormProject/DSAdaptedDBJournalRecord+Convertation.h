//
//  DSAdaptedDBJournalRecord+Convertation.h
//  ReporterProject
//
//  Created by Alexandr Babenko on 22.07.16.
//  Copyright © 2016 Alexandr Babenko. All rights reserved.
//


#import "DSAdaptedDBJournalRecord.h"

@class DSAdaptedObjectsFactory;
@class DSJournalRecord;

@interface DSAdaptedDBJournalRecord (Convertation)


+ (instancetype)adaptedModelForRecord:(DSJournalRecord*)convertingRecord fromBlankModel:(DSAdaptedDBJournalRecord*)blankAdaptedRecord;
- (DSJournalRecord*)convertToJournalRecord;


@end
