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

@interface DSJournalUnitTest : XCTestCase

@end

@implementation DSJournalUnitTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

/*
 @property (strong, nonatomic) NSNumber *recordNumber;
 @property (copy, nonatomic) NSString *recordDescription;
 
 @property (copy, nonatomic) NSDate *recordDate;
 @property (copy, nonatomic) NSDictionary *recordInfo;
 
 @property (assign, nonatomic) DSRecordLogLevel recordLogLevel;
 */


// добавление простой записи, чтобы добавлялась соотв, запись
// проверить самые разные валидные записи
//

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

- (void)testUnlimitedJournalPerformance{
    
    DSJournal *journalUnderTest = [DSJournal new];
    
    const NSUInteger iterationCount = 1000000;
    journalUnderTest.maxCountStoredRecords = UINT_MAX;
    [self measureBlock:^{
        for (NSUInteger iterationIndex = 0; iterationIndex < iterationCount; iterationIndex ++) {
            [journalUnderTest addLogRecord:@"New Recordx" withInfo:nil];
        }
    }];
    
    [journalUnderTest clearJournal];
    
    
}

- (void)testLimitedJournalPerformance{
    
    DSJournal *journalUnderTest = [DSJournal new];
    // Проверить на соотв. кол-во записей
    
    const NSUInteger iterationCount = 1000000;
    [self measureBlock:^{
        for (NSUInteger iterationIndex = 0; iterationIndex < iterationCount; iterationIndex ++) {
            [journalUnderTest addLogRecord:@"New Recordx" withInfo:nil];
        }
    }];
    
    [journalUnderTest clearJournal];
}

// тест с добавлением большого количества записей, проверка вырванных из контекста записей
// тест на очистку большого журнала

// тест с добавлением миллиона записей в журнал))) (для случая с ограничением по количеству, и случая с огромным максимальным количеством)


- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        
        
    }];
}

@end
