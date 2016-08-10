//
//  DSStoreDataProvidingProtocol.h
//  DeepStormProject
//
//  Created by Alexandr Babenko on 10.08.16.
//  Copyright © 2016 Alexandr Babenko. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DSBaseLoggedService, DSJournal, DSJournalRecord;

@protocol DSStoreDataProvidingProtocol <NSObject>

@required
- (NSArray<DSBaseLoggedService*>*)getAllServices;
- (NSArray<DSJournal*>*)getAllJournals;
- (NSArray<DSJournalRecord*>*)getAllRecords;

- (DSJournal*)getJournalForName:(NSString*)journalName;
- (DSBaseLoggedService*)getServiceByTypeID:(NSNumber*)serviceTypeID orByClass:(NSString*)serviceClass;

@end
