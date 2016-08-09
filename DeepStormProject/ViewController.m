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

@interface ViewController ()

@end

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
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
    
    
    DSLocalSQLDatabase *localDB = [DSLocalSQLDatabase sharedDeepStormLocalDatabase];
    DSAdaptedObjectsFactory *modelsFactory = localDB.modelsFactory;
    
    
    
    NSArray <DSAdaptedDBJournal*> *journals = [localDB loadAllJournals];
    NSArray <DSAdaptedDBService*> *services = [localDB loadAllServices];
    NSArray <DSAdaptedDBJournalRecord*> *records = [localDB loadAllRecords];
    
    
    DSAdaptedDBJournal *firstAdaptedJournal = [modelsFactory adaptedModelFromJournal:firstJournalObject];
    DSAdaptedDBJournal *secondAdaptedJournal = [modelsFactory adaptedModelFromJournal:secondJournalObject];
    
    DSAdaptedDBJournalRecord *firstAdaptedRecord = [modelsFactory adaptedModelFromRecord:firstTestRecord];
    DSAdaptedDBJournalRecord *secondAdaptedRecord = [modelsFactory adaptedModelFromRecord:secondTestRecord];
    
    TSVCLocationManager *testService = [TSVCLocationManager sharedLocationManager];
    [testService injectDependencies];
    [testService prepareGeolocation];
    
    NSError *testEmergError = [NSError errorWithDomain:@"testDomain" code:10 userInfo:@{@5 : @"12"}];
    //[testService fixateEmergercySituationWithError:testEmergError];
    
    DSAdaptedDBService *testAdaptedService = [modelsFactory adaptedModelFromService:testService];
    
    
    NSError *savingError = nil;
    BOOL saveSuccess = [localDB.managedObjectContext save:&savingError];
    if(! saveSuccess){
        NSLog(@"BAD SAVING WITH ERROR : %@", savingError);
    }
    
    NSArray <DSAdaptedDBJournal*> *journals2 = [localDB loadAllJournals];
    NSArray <DSAdaptedDBService*> *services2 = [localDB loadAllServices];
    NSArray <DSAdaptedDBJournalRecord*> *records2 = [localDB loadAllRecords];
    NSLog(@"");
    
    
    /*
     _emailReporter2 = [DSEmailReporter new];
     [_emailReporter2 addDestinationEmail:@"hikto583004@list.ru"];
     
     
     dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
     
     DSREPORT_FULL(_emailReporter2);
     });
     
     return;
     */
    
    /*
     
     NSError *testError = [NSError errorWithDomain:@"on.good.domain" code:10 userInfo:@{@"new" : @5}];
     [self addNewError:testError];
     
     
     [self addNewJournalWithName:@"FirstJournal" withClass:@"DSJournal" withCurrentCount:@56 withMaxCount:@80 withOutputStreamingState:@YES];
     
     [self addNewServiceWithServiceClass:@"TZNetworkCore" withTypeID:@12 withWorkingMode:@"WORKING IN NORMAL MODE" withEmergencyError:@"Error !!!" withJournalID:@10];
     
     
     DSLocalSQLDatabase *localDB = [DSLocalSQLDatabase sharedDeepStormLocalDatabase];
     NSFetchRequest *journalsFetchRequest = [NSFetchRequest new];
     NSEntityDescription *journalEntity = [NSEntityDescription entityForName:@"Journal" inManagedObjectContext:localDB.managedObjectContext];
     [journalsFetchRequest setEntity:journalEntity];
     
     NSError *fetchError = nil;
     NSArray <DSAdaptedDBJournal*> *journals = [localDB.managedObjectContext executeFetchRequest:journalsFetchRequest error:&fetchError];
     
     if(! journals || fetchError){
     NSLog(@"FETCH REQUEST ERROR : %@", fetchError);
     }
     
     NSFetchRequest *errorsFetchRequest = [NSFetchRequest new];
     NSEntityDescription *errorEntity = [NSEntityDescription entityForName:@"Error" inManagedObjectContext:localDB.managedObjectContext];
     [errorsFetchRequest setEntity:errorEntity];
     
     fetchError = nil;
     NSArray <DSAdaptedDBError*> *errors = [localDB.managedObjectContext executeFetchRequest:errorsFetchRequest error:&fetchError];
     
     if(! errors || fetchError){
     NSLog(@"FETCH REQUEST ERROR : %@", fetchError);
     }
     */
    
    return;
    
    
    
    
    _emailReporter = [DSEmailHiddenReporter new];
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
    
    
    
    
    
    _fileReporter = [DSFileReporter fileReporterWithMappingType:DSJournalObjectXMLMapping];
    
    
    [firstJournalObject enumerateRecords:^(DSJournalRecord *currentRecord) {
        
        [_fileReporter sendNewRecords:@[currentRecord] forJournal:firstJournalObject];
    }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        
        
        
    });
    
    return;
    
    
    /*
     
     _testStreamer = [DSBasePeriodicStreamer streamerWithInterval:5.0f];
     
     [_testStreamer addStreamingEntity:firstJournalObject];
     [_testStreamer addStreamingEntity:secondJournalObject];
     
     _testStreamer.eventProducer = _emailReporter;
     _testStreamer.eventExecutor = _emailReporter;
     
     [_testStreamer startStreaming];
     
     dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(16.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
     
     [_testStreamer stopStreaming];
     });
     */
    
    return;
    
}

- (BOOL)addNewJournalWithName:(NSString*)journalName withClass:(NSString*)journalClassString withCurrentCount:(NSNumber*)currentCount withMaxCount:(NSNumber*)maxCount withOutputStreamingState:(NSNumber*)streamingState{
    
    DSLocalSQLDatabase *localDB = [DSLocalSQLDatabase sharedDeepStormLocalDatabase];
    DSAdaptedObjectsFactory *modelsFactory = localDB.modelsFactory;
    DSAdaptedDBJournal *newJournal = [modelsFactory generateEmptyJournal];
    
    newJournal.journalName = journalName;
    newJournal.journalClass = journalClassString;
    newJournal.currentCount = currentCount;
    newJournal.maxCount = maxCount;
    newJournal.outputStreamingState = streamingState;
    
    
    NSError *savingError = nil;
    BOOL saveSuccess = [localDB.managedObjectContext save:&savingError];
    if(saveSuccess){
        NSLog(@"ADDED JOURNAL : %@", newJournal);
    }else{
        NSLog(@"BAD SAVING WITH ERROR : %@", savingError);
    }
    
    return saveSuccess;
}


- (BOOL)addNewServiceWithServiceClass:(NSString*)serviceClass withTypeID:(NSNumber*)serviceTypeID withWorkingMode:(NSString*)workingMode withEmergencyError:(NSString*)emergencyError withJournalID:(NSNumber*)journalID{
    
    DSLocalSQLDatabase *localDB = [DSLocalSQLDatabase sharedDeepStormLocalDatabase];
    DSAdaptedObjectsFactory *modelsFactory = localDB.modelsFactory;
    DSAdaptedDBService *newService = [modelsFactory generateEmptyService];
    
    newService.serviceClass = serviceClass;
    newService.typeID = serviceTypeID;
    newService.workingMode = workingMode;
    
    NSError *savingError = nil;
    BOOL saveSuccess = [localDB.managedObjectContext save:&savingError];
    if(saveSuccess){
        NSLog(@"ADDED JOURNAL : %@", newService);
    }else{
        NSLog(@"BAD SAVING WITH ERROR : %@", savingError);
    }
    
    return saveSuccess;
}

- (BOOL)addNewError:(NSError*)testError{
    
    DSLocalSQLDatabase *localDB = [DSLocalSQLDatabase sharedDeepStormLocalDatabase];
    DSAdaptedObjectsFactory *modelsFactory = localDB.modelsFactory;
    DSAdaptedDBError *newError = [modelsFactory generateEmptyError];
    
    newError.code = @(testError.code);
    newError.domain = testError.domain;
    newError.localizedDescription = testError.localizedDescription;
    
    newError.embeddedError = testError;
    
    NSError *savingError = nil;
    BOOL saveSuccess = [localDB.managedObjectContext save:&savingError];
    if(saveSuccess){
        NSLog(@"ADDED ERROR : %@", newError);
    }else{
        NSLog(@"BAD SAVING WITH ERROR : %@", savingError);
    }
    
    return saveSuccess;
}


@end
