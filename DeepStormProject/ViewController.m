//
//  ViewController.m
//  DeepStormProject
//
//  Created by Alexandr Babenko on 07.08.16.
//  Copyright © 2016 Alexandr Babenko. All rights reserved.
//

#import "ViewController.h"

#import "DSTCPBaseServer.h"
#import "DSTCPConnection.h"

#import "DeepStorm.h"
#import "DSBasePeriodicStreamer.h"

#import "DSLocalSQLDatabase.h"
#import "DSAdaptedDBJournal.h"
#import "DSAdaptedDBService.h"
#import "DSAdaptedDBError.h"
#import "DSAdaptedDBJournalRecord.h"

#import "TSVCLocationManager.h"

#import "DSLocalSQLDatabaseReporter.h"
#import "DSWebServerReporter.h"

#import "DSLocalSQLEntitiesProvider.h"

@interface ViewController ()

@end

@implementation ViewController{
    
    DSEmailReporter *_emailReporter2;
    DSEmailHiddenReporter *_emailReporter;
    DSFileReporter *_fileReporter;
    DSBasePeriodicStreamer *_testStreamer;
    DSWebServerReporter<DSStreamingEventFullProtocol> *_webServerReporter;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //[DSLocalSQLEntitiesProvider setRelationsBetweenEntitiesWithKeys:DSEntityServiceKey:DSEntityJournalKey];
    
    static NSString *firstJournal = @"firstJrn";
    static NSString *secondJournal = @"secondJrn";
    
    DSJRN_LOG(firstJournal, @"Die or Life");
    DSJRN_EXT_LOG(firstJournal, @{@"knight" : @"right"}, @"Hop hey lalaley");
    DSJRN_INFO_LOG(firstJournal, @"First Lifer");
    DSJRN_VERBOSE_LOG(firstJournal, @"Second Lifer");
    DSJRN_MEDIUM_LOG(firstJournal, @"Third Lifer");
    DSJRN_HARD_LOG(firstJournal, @"4 Lifer");
    DSJRN_WARNING_LOG(firstJournal, @"5 Lifer");
    DSJRN_ERROR_LOG(firstJournal, @"6 Lifer");
    
    DSJRN_INFO_EXT_LOG(firstJournal, @{@5 : @7}, @"1 ext");
    DSJRN_EXT_LEVEL_LOG(firstJournal, @{@6 : @"heh"}, DSRecordLogLevelWarning, @"2 ext bastard");
    DSJRN_INFO_EXT_LOG(firstJournal, @{@7 : @"heh"}, @"3 ext bastard");
    DSJRN_VERBOSE_EXT_LOG(firstJournal, @{@8 : @"heh"}, @"4 ext bastard");
    DSJRN_MEDIUM_EXT_LOG(firstJournal, @{@9 : @"heh"}, @"5 ext bastard");
    DSJRN_HARD_EXT_LOG(firstJournal, @{@10 : @"heh"}, @"6 ext bastard");
    DSJRN_WARNING_EXT_LOG(firstJournal, @{@11 : @"heh"}, @"7 ext bastard");
    DSJRN_ERROR_EXT_LOG(firstJournal, @{@12 : @"heh"}, @"8 ext bastard");
    
    DSJRN_LOG(secondJournal, @"First Record in second journal!");
    
    
    DSExternalJournalCloud *defaultCloud = [DSExternalJournalCloud sharedCloud];
    DSJournal *firstJournalObject = [defaultCloud journalByName:firstJournal];
    DSJournal *secondJournalObject = [defaultCloud journalByName:secondJournal];
    
    DSJournalRecord *firstTestRecord = [firstJournalObject getRecordWithNumber:@1];
    DSJournalRecord *secondTestRecord = [firstJournalObject getRecordWithNumber:@2];
    
    
    
    _webServerReporter = [DSWebServerReporter extendedWebServerReporter];
    id<DSStoreDataProvidingProtocol> dbDataProvider = _webServerReporter.localDB;
    
    NSArray <DSJournal*> *journals = [dbDataProvider getAllJournals];
    NSArray <DSBaseLoggedService*> *services = [dbDataProvider getAllServices];
    NSArray <DSJournalRecord*> *records = [dbDataProvider getAllRecords];
    
    
    [_webServerReporter setReportingCompletion:^(BOOL isSuccessSending, NSError *sendingError){
        NSLog(@"DB REPORTING COMPLETION");
    }];
    
    
    TSVCLocationManager *testService = [TSVCLocationManager sharedLocationManager];
    [testService injectDependencies];
    [testService prepareGeolocation];
    
    DSREPORT_FULL(_webServerReporter);
    
    //[_localDBReporter addPartReportService:testService];
    
    //[_localDBReporter performAllReports];
    
    
    NSArray <DSJournal*> *journals2 = [dbDataProvider getAllJournals];
    NSArray <DSBaseLoggedService*> *services2 = [dbDataProvider getAllServices];
    NSArray <DSJournalRecord*> *records2 = [dbDataProvider getAllRecords];
    NSLog(@"");
    
    /*
    
    return;
    
    
    
    
    _emailReporter = [DSEmailHiddenReporter extendedEmailReporter];
    [_emailReporter addDestinationEmail:@"hikto583004@list.ru"];
    [_emailReporter setDecryptorWithIV:@"1234567890abcdef1234567890abcdef" withKey:@"D8578EDF8458CE06FBC5BB76A58C5CA4D8578EDF8458CE06FBC5BB76A58C5CA4"];
    [_emailReporter addConfigSMTPSession:^(MCOSMTPSession *smtpSession) {
        
        [smtpSession setHostname:@"smtp.mail.ru"];
        [smtpSession setPort:465];
        [smtpSession setConnectionType:MCOConnectionTypeTLS];
    }];
    [_emailReporter setReportingCompletion:^(BOOL isSuccessSending, NSError *sendingError){
        NSLog(@"REPORTING COMPLETION");
    }];
    
    
    DSREPORT_FULL(_emailReporter);
    
    return;
    
    */
    
     
    _testStreamer = [DSBasePeriodicStreamer streamerWithInterval:1.0f];
    
    [_testStreamer addStreamingEntity:firstJournalObject];
    [_testStreamer addStreamingEntity:secondJournalObject];
    [_testStreamer addStreamingEntity:testService];
    
    _testStreamer.eventProducer = _webServerReporter;
    _testStreamer.eventExecutor = _webServerReporter;
    
    [_testStreamer startStreaming];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(40.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [_testStreamer stopStreaming];
    });
    
    
    return;
    
}

@end
