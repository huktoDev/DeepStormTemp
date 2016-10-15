//
//  DSJournalBaseUnitTest.h
//  DeepStormProject
//
//  Created by Alexandr Babenko (HuktoDev) on 15.10.16.
//  Copyright © 2016 Alexandr Babenko. All rights reserved.
//

#ifndef DSJournalBaseUnitTest_h
#define DSJournalBaseUnitTest_h

#import <XCTest/XCTest.h>

@class DSJournal, DSJournalRecord;

@interface DSJournalBaseUnitTest : XCTestCase

- (NSUInteger)addRandomRecordToJournal:(DSJournal*)journal;
- (void)addRecordWithCase:(NSUInteger)recordCase toJournal:(DSJournal*)journal;

- (void)checkRecord:(DSJournalRecord*)record byCase:(NSUInteger)testCase;

@end

#endif /* DSJournalBaseUnitTest_h */
