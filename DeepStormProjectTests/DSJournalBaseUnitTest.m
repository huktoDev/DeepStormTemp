//
//  DSJournalBaseUnitTest.m
//  DeepStormProject
//
//  Created by Alexandr Babenko (HuktoDev) on 15.10.16.
//  Copyright © 2016 Alexandr Babenko. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "DSJournalBaseUnitTest.h"

#import "DSJournal.h"
#import "DSJournalRecord.h"

@implementation DSJournalBaseUnitTest

#pragma mark - Supplementary Methods -

- (NSUInteger)addRandomRecordToJournal:(DSJournal*)journal{
    
    NSUInteger randValue = arc4random() % 5;
    [self addRecordWithCase:randValue toJournal:journal];
    return randValue;
}

- (void)addRecordWithCase:(NSUInteger)recordCase toJournal:(DSJournal*)journal{
    if(recordCase == 0){
        [journal addLogRecord:@"TestRec" withInfo:nil];
    }else if(recordCase == 1){
        [journal addLogRecord:@"TestRec2" withInfo:@{@5 : @"11", @"Check" : @0}];
    }else if(recordCase == 2){
        [journal addLogRecord:@"TestRec3" withInfo:@{@5 : @"11", @"Check" : @0, DSRecordLogLevelParamKey : @(DSRecordLogLevelHighest)}];
    }else if(recordCase == 3){
        [journal addLogRecord:@"Unbelivable" withInfo:@{DSRecordLogLevelParamKey : @(DSRecordLogLevelMedium)}];
    }else if(recordCase == 4){
        [journal addLogWithInfo:@{@5 : @"11", @"Check" : @0, DSRecordLogLevelParamKey : @(DSRecordLogLevelInfo)} withFormat:@"New Records with values %@, %d", @"123", 123];
    }
}

- (void)checkRecord:(DSJournalRecord*)record byCase:(NSUInteger)testCase{
    
    if(testCase == 0){
        
        XCTAssertTrue([record.recordDescription isEqualToString:@"TestRec"], @"Description don't equivalent");
        XCTAssertNil(record.recordInfo, @"Record have unexcepted Info dictionary %@", record.recordInfo);
        XCTAssertTrue((record.recordLogLevel == DSRecordLogLevelDefault), @"Record have wrong non-default Log Level %d", record.recordLogLevel);
        
    }else if(testCase == 1){
        
        XCTAssertTrue([record.recordDescription isEqualToString:@"TestRec2"], @"Description don't equivalent");
        BOOL haveRightInfoDict = (record.recordInfo.count == 2) && [record.recordInfo objectForKey:@"5"];
        XCTAssertTrue(haveRightInfoDict, @"UserInfo dictionary Incorrect for case %d : %@", testCase, record.recordInfo);
        XCTAssertTrue((record.recordLogLevel == DSRecordLogLevelDefault), @"Record have wrong non-default Log Level %d", record.recordLogLevel);
        
    }else if(testCase == 2){
        
        XCTAssertTrue([record.recordDescription isEqualToString:@"TestRec3"], @"Description don't equivalent");
        BOOL haveRightInfoDict = (record.recordInfo.count == 2) && [record.recordInfo objectForKey:@"5"] && (! [record.recordInfo objectForKey:DSRecordLogLevelParamKey]);
        
        XCTAssertTrue(haveRightInfoDict, @"UserInfo dictionary Incorrect for case %d : %@", testCase, record.recordInfo);
        XCTAssertTrue((record.recordLogLevel == DSRecordLogLevelHighest), @"Record have wrong non-Highest Log Level %d", record.recordLogLevel);
        
    }else if(testCase == 3){
        
        XCTAssertTrue([record.recordDescription isEqualToString:@"Unbelivable"], @"Description don't equivalent");
        BOOL haveRightInfoDict = !record.recordInfo || (record.recordInfo.count == 0);
        XCTAssertTrue(haveRightInfoDict, @"UserInfo dictionary Incorrect for case %d : %@", testCase, record.recordInfo);
        XCTAssertTrue((record.recordLogLevel == DSRecordLogLevelMedium), @"Record have wrong non-Medium Log Level %d", record.recordLogLevel);
        
    }else if(testCase == 4){
        
        XCTAssertTrue([record.recordDescription isEqualToString:@"New Records with values 123, 123"], @"Description don't equivalent");
        BOOL haveRightInfoDict = (record.recordInfo.count == 2);
        XCTAssertTrue(haveRightInfoDict, @"UserInfo dictionary Incorrect for case %d : %@", testCase, record.recordInfo);
        XCTAssertTrue((record.recordLogLevel == DSRecordLogLevelInfo), @"Record have wrong non-Info Log Level %d", record.recordLogLevel);
        
    }
}

@end
