//
//  DSJournalRecordUnitTest.m
//  DeepStormProject
//
//  Created by Alexandr Babenko (HuktoDev) on 09.10.16.
//  Copyright © 2016 Alexandr Babenko. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "DSJournalRecord.h"
#import "DSEntityProtocol.h"

@interface DSJournalRecordUnitTest : XCTestCase
@end


@implementation DSJournalRecordUnitTest

- (void)testOnDeepStormEntity{
    
    DSJournalRecord *recordUnderTest = [DSJournalRecord new];
    
    XCTAssertNoThrow(recordUnderTest.entityKey, @"%@ can implement %@ property", recordUnderTest, NSStringFromSelector(@selector(entityKey)));
    
    BOOL isRightKey = (recordUnderTest.entityKey == DSEntityRecordKey);
    XCTAssertTrue(isRightKey, @"Key for this entity isn't match with right Key");
}

- (void)testOnRightProperties{
    
    DSJournalRecord *recordUnderTest = [DSJournalRecord new];
    
    [self checkExistPropertyWithGetter:@selector(recordNumber) inObject:recordUnderTest];
    [self checkExistPropertyWithGetter:@selector(recordDescription) inObject:recordUnderTest];
    [self checkExistPropertyWithGetter:@selector(recordDate) inObject:recordUnderTest];
    [self checkExistPropertyWithGetter:@selector(recordInfo) inObject:recordUnderTest];
    [self checkExistPropertyWithGetter:@selector(recordLogLevel) inObject:recordUnderTest];
}

- (void)testOnLogDescription{
    
    BOOL isRightInfoDescription = [DSLogLevelDescription(DSRecordLogLevelInfo) isEqualToString:@"INFO"];
    BOOL isRightWarningDescription = [DSLogLevelDescription(DSRecordLogLevelWarning) isEqualToString:@"WARNING"];
    XCTAssertTrue(isRightInfoDescription && isRightWarningDescription, @"Incorrect LogLevel Description. See DSLogLevelDescription() function");
}

- (void)checkExistPropertyWithGetter:(SEL)getterSelector inObject:(id)checkingObj{
    
    NSString *getterString = NSStringFromSelector(getterSelector);
    NSString *setterString = [NSString stringWithFormat:@"set%@%@:", [[getterString substringToIndex:1] uppercaseString], [getterString substringFromIndex:1]];
    
    SEL setterSelector = NSSelectorFromString(setterString);
    
    BOOL haveTwoWayProperty = [checkingObj respondsToSelector:getterSelector] && [checkingObj respondsToSelector:setterSelector];
    XCTAssertTrue(haveTwoWayProperty, @"Object %@ must have property %@", checkingObj, getterString);
}


@end
