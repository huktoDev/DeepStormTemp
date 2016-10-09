//
//  DSJournalRecord.m
//  DeepStormProject
//
//  Created by Alexandr Babenko (HuktoDev) on 09.10.16.
//  Copyright © 2016 Alexandr Babenko. All rights reserved.
//

#import "DSJournalRecord.h"
#import "DSEntityProtocol.h"

/// Строкое описание Log-Level-а
NSString* DSLogLevelDescription(DSRecordLogLevel logLevel){
    
    switch (logLevel) {
        case DSRecordLogLevelInfo:
            return @"INFO";
        case DSRecordLogLevelVerbose:
            return @"VERBOSE";
        case DSRecordLogLevelMedium:
            return @"MEDIUM";
        case DSRecordLogLevelHard:
            return @"HARD";
        case DSRecordLogLevelWarning:
            return @"WARNING";
        case DSRecordLogLevelError:
            return @"ERROR";
        default:
            return @"";
    }
}

@implementation DSJournalRecord

- (DSEntityKey)entityKey{
    return DSEntityRecordKey;
}

@end
