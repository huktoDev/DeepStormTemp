//
//  DSEntityJSONMapperTest.m
//  DeepStormProject
//
//  Created by Alexandr Babenko (HuktoDev) on 14.10.16.
//  Copyright © 2016 Alexandr Babenko. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "DSJournal.h"
#import "DSJournalRecord.h"
#import "DSJournalMappingProtocol.h"
#import "DSJournalBaseUnitTest.h"

@interface DSEntityJSONMapperTest : DSJournalBaseUnitTest

@property (strong, nonatomic) DSJournal *journalUnderTest;
@property (strong, nonatomic) Class<DSJournalMappingProtocol> jsonMappingClass;

@end

@implementation DSEntityJSONMapperTest

- (void)setUp {
    [super setUp];
    
    self.journalUnderTest = [DSJournal new];
    self.jsonMappingClass = GetObjectMapperClassByMappingType(DSJournalObjectJSONMapping);
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

// проверка пустого журнала
// проверка журнала с набором записей
// проверка для каждого свойства/тэга
// проверка, чтобы создавало корректный тег для записи (тесты должны знать Protected interface)
// добавить journalName тэг


// добавить level, color тэг
// добавить
// проверить парсинг JSON-а в модель


- (void)testEmptyJournalJSONRepresentation{
    
    [self checkJournalWithJSONRegExp:self.journalUnderTest];
}

- (void)testJournalOneRecordJSONRepresentation{
    
    [self.journalUnderTest addLogRecord:@"TestRecord" withInfo:nil];
    [self.journalUnderTest addLogRecord:@"TestRecord2" withInfo:nil];
    
    [self checkJournalWithJSONRegExp:self.journalUnderTest];
}

- (void)testComplexJournalJSONRepresentation{
    
    self.journalUnderTest.maxCountStoredRecords = 200;
    self.journalUnderTest.journalName = @"TestName";
    
    for (NSUInteger recordCase = 0; recordCase < 5; recordCase ++) {
        [self addRecordWithCase:recordCase toJournal:self.journalUnderTest];
    }
    
    [self checkJournalWithJSONRegExp:self.journalUnderTest];
}

- (NSString*)baseJournalRegExpPatternStringByJournal:(DSJournal*)journal{
    
    NSMutableString *innerRecordArrayString = [NSMutableString new];
    [journal enumerateRecords:^(DSJournalRecord *record) {
        
        NSMutableString *recordString = [NSMutableString new];
        
        if(record.recordInfo.count > 0){
            
            NSString *recordInfoJSONString = @"\\{(\\s{0,21})(\"([^\n]|\n){1,16}\"( )?:( )?(([^\n]|\n){1,16}),?(\\s{0,21})){1,2}\\}";
            [recordString appendFormat:@"\"userInfo\"( )?:( )?%@,?(\\s{0,18})", recordInfoJSONString];
        }
        
        [recordString appendFormat:@"\"description\"( )?:( )?\"%@\",?(\\s{0,18})", record.recordDescription];
        [recordString appendFormat:@"\"number\"( )?:( )?%@,?(\\s{0,18})", record.recordNumber];
        
        NSString *dateString = [record.recordDate description];
        dateString = [dateString stringByReplacingOccurrencesOfString:@"+" withString:@"\\+"];
        [recordString appendFormat:@"\"date\"( )?:( )?\"%@\",?(\\s{0,18})", dateString];
        
        [innerRecordArrayString appendFormat:@"\\{(\\s{0,15})\"record\"( )?:( )?\\{(\\s{0,18})%@\\}(\\s{0,18})\\},?(\\s{0,15})", recordString];
    }];
    
    return [NSString stringWithFormat:@"\\{(\\s{0,5})\"journal\"( )?:( )?\\{(\\s{0,8})\"name\"( )?:( )?\"%@\",(\\s{0,8})\"maxRecords\"( )?:( )?%@,(\\s{0,8})\"recordsCount\"( )?:( )?%@,(\\s{0,8})\"recordsArray\"( )?:( )?\\[(\\s{0,10})%@(\\s{0,10})\\](\\s{0,8})\\}", journal.journalName ,@(journal.maxCountStoredRecords), @(journal.countRecords), innerRecordArrayString];
}



- (NSRegularExpression*)JSONJournalRegExpByJournal:(DSJournal*)journal{
    
    NSString *jsonRegExpString = [self baseJournalRegExpPatternStringByJournal:journal];
    NSError *regExpErr = nil;
    NSRegularExpression *baseJsonRegExp = [NSRegularExpression regularExpressionWithPattern:[NSString stringWithFormat:@"^%@$", jsonRegExpString] options:NSRegularExpressionAnchorsMatchLines error:&regExpErr];
    
    XCTAssertNil(regExpErr, @"RegularExpression for JSON can not created, because error occured %@", regExpErr);
    XCTAssertNotNil(baseJsonRegExp, @"RegularExpression for JSON returned nil");
    
    return baseJsonRegExp;
}

- (void)checkJournalWithJSONRegExp:(DSJournal*)journal{
    
    NSData *journalData = [self.jsonMappingClass dataRepresentationForJournal:journal];
    NSString *journalString = [[NSString alloc] initWithData:journalData encoding:NSUTF8StringEncoding];
    
    NSRegularExpression *jsonRegExpJournal = [self JSONJournalRegExpByJournal:journal];
    NSUInteger countMatches = [jsonRegExpJournal numberOfMatchesInString:journalString options:0 range:NSMakeRange(0, journalString.length)];
    
    XCTAssertTrue((countMatches == 1), @"JSON for Journal have incorrect presentation : %@", journalString);
}

@end
