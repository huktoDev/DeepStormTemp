//
//  DSJournalUnitTest.m
//  DeepStormProject
//
//  Created by Alexandr Babenko (HuktoDev) on 09.10.16.
//  Copyright © 2016 Alexandr Babenko. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "DSJournal.h"
#import "DSJournalRecord.h"
#import "DSJournalBaseUnitTest.h"

@interface DSJournalUnitTest : DSJournalBaseUnitTest

@end

@implementation DSJournalUnitTest{
    @private
    dispatch_source_t _waitingLockTimer;
}


#pragma mark - Test Methods -

/// Манипуляции с пустым журналом
- (void)testEmptyJournal{
    
    DSJournal *journalUnderTest = [DSJournal new];
    
    BOOL haveEmptyRecords = (journalUnderTest.countRecords == 0);
    DSJournalRecord *emptyJournalRecord1 = [journalUnderTest getRecordWithNumber:@0];
    DSJournalRecord *emptyJournalRecord2 = [journalUnderTest getRecordWithNumber:@1];
    XCTAssertNil(emptyJournalRecord1, @"Empty journal shouldn't return Record objects");
    XCTAssertNil(emptyJournalRecord2, @"Empty journal shouldn't return Record objects");
    XCTAssertTrue(haveEmptyRecords, @"Start Records count must be zero!");
    
    @try {
        [journalUnderTest enumerateRecords:^(DSJournalRecord *record) {}];
        [journalUnderTest enumerateRecords:nil];
        [journalUnderTest enumerateLast:0 records:nil];
        [journalUnderTest enumerateLast:5 records:nil];
        [journalUnderTest enumerateLast:6 records:^(DSJournalRecord *record) {record.recordDescription = @"New";}];
        [journalUnderTest clearJournal];
    } @catch (NSException *exception) {
        XCTAssertTrue(NO, @"One of executed methods throw an exception :\n%@ : %@", exception.name, exception.reason);
    }
}

/// Манипуляции с добавлением простой записи
- (void)testAddSimpleRecordBase{
    
    DSJournal *journalUnderTest = [DSJournal new];
    
    [journalUnderTest addLogRecord:@"TestRec1" withInfo:nil];
    
    BOOL haveOnlyOneRecord = (journalUnderTest.countRecords == 1);
    XCTAssertTrue(haveOnlyOneRecord, @"Have wrong count records after adding 1 record : %d", journalUnderTest.countRecords);
    
    DSJournalRecord *zeroJournalRecord = [journalUnderTest getRecordWithNumber:@0];
    DSJournalRecord *firstJournalRecord = [journalUnderTest getRecordWithNumber:@1];
    DSJournalRecord *secondJournalRecord = [journalUnderTest getRecordWithNumber:@2];
    
    XCTAssertNil(zeroJournalRecord, @"Zero number record always can be nil");
    XCTAssertNotNil(firstJournalRecord, @"Record wasn't added to Journal");
    XCTAssertNil(secondJournalRecord, @"Second number record must be nil");
    
    XCTAssertEqual(firstJournalRecord.recordDescription, @"TestRec1", @"Records descriptions isn't equals");
    XCTAssertTrue([firstJournalRecord.recordNumber isEqualToNumber:@1], @"Incorrect JournalRecord number");
    XCTAssertTrue((firstJournalRecord.recordLogLevel == DSRecordLogLevelDefault), @"Dont Assigned to Record right Default LogLevel");
    XCTAssertNotNil(firstJournalRecord.recordDate, @"To Journal Record wasn't assigned Date");
    
    NSTimeInterval intervalAfterCreation = -([firstJournalRecord.recordDate timeIntervalSinceNow]);
    BOOL isRecentlyDate = (intervalAfterCreation < 0.001f && intervalAfterCreation > -0.001f);
    XCTAssertTrue(isRecentlyDate, @"Was assigned incorrect Date to Record");
    
    XCTAssertNil(firstJournalRecord.recordInfo, @"Record Info for very simple record can be nil always");
}

/// Манипуляции с энумерациями, когда в журнале одна запись
- (void)testAddSimpleRecordEnumeration{
    
    DSJournal *journalUnderTest = [DSJournal new];
    [journalUnderTest addLogRecord:@"TestRec1" withInfo:nil];
    
    DSJournalRecord *firstJournalRecord = [journalUnderTest getRecordWithNumber:@1];

    @try {
        [journalUnderTest enumerateRecords:^(DSJournalRecord *record) {
            if([record.recordNumber unsignedIntegerValue] == 1){
                XCTAssertEqual(firstJournalRecord, record, @"Found incorrect record in Journal with one record");
            }else{
                XCTAssertTrue(NO, @"Were found incorrect record or incorrect calling of Enumeration block");
            }
        }];
        [journalUnderTest enumerateRecords:nil];
        [journalUnderTest enumerateLast:0 records:nil];
        [journalUnderTest enumerateLast:0 records:^(DSJournalRecord *record) {}];
        [journalUnderTest enumerateLast:1 records:nil];
        [journalUnderTest enumerateLast:1 records:^(DSJournalRecord *record) {}];
        [journalUnderTest enumerateLast:2 records:nil];
        [journalUnderTest enumerateLast:5 records:^(DSJournalRecord *record) {
            if([record.recordNumber unsignedIntegerValue] == 1){
                XCTAssertEqual(firstJournalRecord, record, @"Found incorrect record in Journal with one record");
            }else{
                XCTAssertTrue(NO, @"Were found incorrect record or incorrect calling of Enumeration block");
            }
        }];
        
        
    } @catch (NSException *exception) {
        XCTAssertTrue(NO, @"One of executed methods throw an exception :\n%@ : %@", exception.name, exception.reason);
    }
}

/// Тест на очистку журнала с одной записью
- (void)testJournalWithOneRecordClearing{
    
    DSJournal *journalUnderTest = [DSJournal new];
    [journalUnderTest addLogRecord:@"TestRec1" withInfo:nil];

    XCTAssertNoThrow([journalUnderTest clearJournal], @"Clearing Journal Executed with exceptions");
    
    XCTAssertTrue((journalUnderTest.countRecords == 0), @"Journal wasn't correctly cleared");
    
    DSJournalRecord *zeroInEmptyJournalRecord = [journalUnderTest getRecordWithNumber:@0];
    DSJournalRecord *firstInEmptyJournalRecord = [journalUnderTest getRecordWithNumber:@1];
    DSJournalRecord *secondInEmptyJournalRecord = [journalUnderTest getRecordWithNumber:@2];
    
    XCTAssertFalse((zeroInEmptyJournalRecord || firstInEmptyJournalRecord || secondInEmptyJournalRecord), @"Journal have non-empty records after clearing");
}

/// Манипуляции с добавлением нескольких записей к журналу
- (void)testJournalWithFewRecords{
    
    DSJournal *firstFulledJournal = [DSJournal new];
    [firstFulledJournal addLogRecord:@"TestRec1" withInfo:nil];
    [firstFulledJournal addLogRecord:@"TestRec2" withInfo:nil];
    [firstFulledJournal addLogRecord:@"ThirdRecord" withInfo:nil];
    
    DSJournal *secondFulledJournal = [DSJournal new];
    [secondFulledJournal addLogRecord:@"TestRec1" withInfo:nil];
    [secondFulledJournal addLogRecord:@"TestRec2" withInfo:nil];
    [secondFulledJournal addLogRecord:@"ThirdRecord" withInfo:nil];
    [secondFulledJournal clearJournal];
    [secondFulledJournal addLogRecord:@"TestRec1" withInfo:nil];
    [secondFulledJournal addLogRecord:@"TestRec2" withInfo:nil];
    [secondFulledJournal addLogRecord:@"ThirdRecord" withInfo:nil];
    
    for (DSJournal *journalUnderTest in @[firstFulledJournal, secondFulledJournal]) {
        
        XCTAssertTrue((journalUnderTest.countRecords == 3), @"Journal don't have 3 Records now");
        
        DSJournalRecord *zeroInEmptyJournalRecord = [journalUnderTest getRecordWithNumber:@0];
        XCTAssertNil(zeroInEmptyJournalRecord, @"Zero record must be nil");
        
        for (NSUInteger recordIndex = 1; recordIndex < 4; recordIndex ++) {
            DSJournalRecord *recoveredJournalRecord = [journalUnderTest getRecordWithNumber:@(recordIndex)];
            XCTAssertNotNil(recoveredJournalRecord, @"Record can not be recovered from Journal");
            if(recordIndex == 3){
                XCTAssertTrue([recoveredJournalRecord.recordDescription isEqualToString:@"ThirdRecord"], @"Record description incorrect, please check");
            }
        }
        
        DSJournalRecord *secondInEmptyJournalRecord = [journalUnderTest getRecordWithNumber:@4];
        XCTAssertNil(secondInEmptyJournalRecord, @"Record after last record must be nil");
        
        __block NSUInteger countRecords = 0;
        [journalUnderTest enumerateRecords:^(DSJournalRecord *record) {
            
            NSUInteger recordIndex = [record.recordNumber unsignedIntegerValue];
            if(recordIndex == 2){
                XCTAssertTrue([record.recordDescription isEqualToString:@"TestRec2"], @"Second record, when enumerate - have incorrect description");
            }
            XCTAssertTrue((recordIndex >= 1 && recordIndex <= 3), @"Record have wrong index when enumerate");
            countRecords ++;
        }];
    }
}

/// Замер времени добавления 100т записей для журнала, неограниченного по их числу
- (void)testUnlimitedJournalPerformance{
    
    DSJournal *journalUnderTest = [DSJournal new];
    
    const NSUInteger iterationCount = 100000;
    journalUnderTest.maxCountStoredRecords = UINT_MAX;
    [self measureBlock:^{
        for (NSUInteger iterationIndex = 0; iterationIndex < iterationCount; iterationIndex ++) {
            [journalUnderTest addLogRecord:@"New Recordx" withInfo:nil];
        }
    }];
    
    [journalUnderTest clearJournal];
}

/// Замер времени добавления 100т записей для журнала, ограниченного по числу записей (старые записи высвобождаются)
- (void)testLimitedJournalPerformance{
    
    DSJournal *journalUnderTest = [DSJournal new];
    
    const NSUInteger iterationCount = 100000;
    [self measureBlock:^{
        for (NSUInteger iterationIndex = 0; iterationIndex < iterationCount; iterationIndex ++) {
            [journalUnderTest addLogRecord:@"New Recordx" withInfo:nil];
        }
    }];
    
    [journalUnderTest clearJournal];
}

/// Тесты на очистку журнала с большим количеством записей
- (void)testOnBigJournalClearing{
    
    for (NSUInteger journalIndex = 0; journalIndex < 2; journalIndex ++) {
        
        DSJournal *journalUnderTest = [DSJournal new];
        if(journalIndex == 1){
            journalUnderTest.maxCountStoredRecords = UINT_MAX;
        }
        
        const NSUInteger iterationCount = 100000;
        for (NSUInteger iterationIndex = 0; iterationIndex < iterationCount; iterationIndex ++) {
            [self addRandomRecordToJournal:journalUnderTest];
        }
        [journalUnderTest clearJournal];
        
        BOOL haveEmptyRecords = (journalUnderTest.countRecords == 0);
        DSJournalRecord *emptyJournalRecord1 = [journalUnderTest getRecordWithNumber:@0];
        DSJournalRecord *emptyJournalRecord2 = [journalUnderTest getRecordWithNumber:@1];
        DSJournalRecord *randomJournalRecord = [journalUnderTest getRecordWithNumber:@1000];
        XCTAssertNil(emptyJournalRecord1, @"Empty journal shouldn't return Record objects");
        XCTAssertNil(emptyJournalRecord2, @"Empty journal shouldn't return Record objects");
        XCTAssertNil(randomJournalRecord, @"Empty journal shouldn't return Record objects");
        XCTAssertTrue(haveEmptyRecords, @"Start Records count must be zero!");
    }
}

/// Тесты на перечисление записей для большого журнала
- (void)testOnBigJournalEnumeration{
    
    for (NSUInteger journalIndex = 0; journalIndex < 2; journalIndex ++) {
        
        DSJournal *journalUnderTest = [DSJournal new];
        if(journalIndex == 0){
            journalUnderTest.maxCountStoredRecords = UINT_MAX;
        }else if(journalIndex == 1){
            journalUnderTest.maxCountStoredRecords = 800;
        }
        
        const NSUInteger iterationCount = 100000;
        for (NSUInteger iterationIndex = 0; iterationIndex < iterationCount; iterationIndex ++) {
            [self addRandomRecordToJournal:journalUnderTest];
        }
        
        DSJournalRecord *selectedRecord1 = [journalUnderTest getRecordWithNumber:@(9700)];
        DSJournalRecord *selectedRecord2 = [journalUnderTest getRecordWithNumber:@(iterationCount - 752)];
        
        __block NSUInteger recordIndex = 0;
        if(journalIndex == 1){
            recordIndex = iterationCount - journalUnderTest.maxCountStoredRecords;
        }
        [journalUnderTest enumerateRecords:^(DSJournalRecord *record) {
            
            BOOL isRightRecord = [record.recordNumber isEqualToNumber:@(recordIndex + 1)];
            XCTAssertTrue(isRightRecord, @"Record, when enumerating have incorrect indexes");
            
            if(recordIndex == (journalUnderTest.maxCountStoredRecords - 752 - 1)){
                XCTAssertEqual(record, selectedRecord2, @"Enumerated Records don't matched");
            }else if(recordIndex == (9700 - 1)){
                XCTAssertEqual(record, selectedRecord1, @"Enumerated Records don't matched");
            }
            
            recordIndex ++;
        }];
        
        recordIndex = 0;
        if(journalIndex == 0){
            recordIndex = (iterationCount - 1000);
        }else if(journalIndex == 1){
            recordIndex = (iterationCount - journalUnderTest.maxCountStoredRecords);
        }
        [journalUnderTest enumerateLast:1000 records:^(DSJournalRecord *record) {
            
            BOOL isRightRecord = [record.recordNumber isEqualToNumber:@(recordIndex + 1)];
            XCTAssertTrue(isRightRecord, @"Record, when enumerating have incorrect indexes");
            
            recordIndex ++;
        }];
        XCTAssertTrue((recordIndex == iterationCount), @"Incorrect enumerated Records count");
        
        if(journalIndex == 1){
            journalUnderTest.maxCountStoredRecords = 800;
            XCTAssertTrue((journalUnderTest.countRecords == journalUnderTest.maxCountStoredRecords), @"Journal successfully wasn't filled fully");
        }
    }
}

/// Проверка на отсутствие гонки за ресурсы журнала ежду потоками
- (void)testOnManipulationLocking{
    
    DSJournal *journalUnderTest = [DSJournal new];
    XCTestExpectation *unlockExpectation = [self expectationWithDescription:@"Action End Expectations"];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        const NSUInteger iterationCount = 100000;
        for (NSUInteger iterationIndex = 0; iterationIndex < iterationCount; iterationIndex ++) {
            [self addRandomRecordToJournal:journalUnderTest];
        }
        [unlockExpectation fulfill];
    });
    
    _waitingLockTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0));
    dispatch_source_set_timer(_waitingLockTimer, DISPATCH_TIME_NOW, 0.1f * NSEC_PER_SEC, 1ull * NSEC_PER_SEC);
    dispatch_source_set_event_handler(_waitingLockTimer, ^{
        
        if(journalUnderTest.countRecords > 50000){
            [journalUnderTest enumerateRecords:^(DSJournalRecord *record) {}];
        }
    });
    dispatch_resume(_waitingLockTimer);
    
    [self waitForExpectationsWithTimeout:2.0f handler:^(NSError * _Nullable error) {
        if (error) {
            XCTAssertNotNil(error, @"Locking problems, Timeout with error %@", error);
        }
    }];
}

/// Стресс-тесты на большое количество записей, тесты с разными типами журналов и разными видами записей
- (void)testOnBigRecordsCount{
    
    DSJournal *journalUnderTest = [DSJournal new];
    
    NSMutableArray *recordsSnapshotsArray = [NSMutableArray new];
    
    const NSUInteger iterationCount = 10000;
    journalUnderTest.maxCountStoredRecords = UINT_MAX;
    for (NSUInteger iterationIndex = 0; iterationIndex < iterationCount; iterationIndex ++) {
        
        NSUInteger recordCase = [self addRandomRecordToJournal:journalUnderTest];
        
        DSJournalRecord *currentAddedJournalRecord = [journalUnderTest getRecordWithNumber:@(iterationIndex+1)];
        [self checkRecord:currentAddedJournalRecord byCase:recordCase];
        
        BOOL needRecordSnapshot = (arc4random() % 200 == 0);
        if(needRecordSnapshot){
            [recordsSnapshotsArray addObject:@{@(iterationIndex+1) : currentAddedJournalRecord}];
        }
    }
    
    for (NSDictionary *snapshotRecordPair in recordsSnapshotsArray) {
        NSUInteger recordCheckIndex = [[[snapshotRecordPair allKeys] firstObject] unsignedIntegerValue];
        DSJournalRecord *snapshottedRecord = [snapshotRecordPair objectForKey:@(recordCheckIndex)];
        
        DSJournalRecord *recordFromJournal = [journalUnderTest getRecordWithNumber:@(recordCheckIndex)];
        XCTAssertEqual(snapshottedRecord, recordFromJournal, @"Real records and snapshotted values don't match %@ %@", snapshottedRecord, recordFromJournal);
    }
}


@end

