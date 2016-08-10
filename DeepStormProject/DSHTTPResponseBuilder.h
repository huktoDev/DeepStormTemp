//
//  DSHTTPResponseBuilder.h
//  DeepStormProject
//
//  Created by Alexandr Babenko on 10.08.16.
//  Copyright © 2016 Alexandr Babenko. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DSStoreDataProvidingProtocol;
@class DSJournalRecord;
@class DSBaseLoggedService;
@class DSJournal;

@interface DSHTTPResponseBuilder : NSObject

+ (instancetype)responseBuilderWithHTMLPattern:(NSString*)htmlPreparedPattern;
+ (instancetype)responseBuilderWithHTMLBaseFrame:(NSString*)htmlFilePath;

- (instancetype)appendSimpleRecord:(DSJournalRecord*)nextRecord;

- (instancetype)appendServiceLink:(DSBaseLoggedService*)linkedService;
- (instancetype)appendServiceDescription:(DSBaseLoggedService*)descriptedService;

- (instancetype)appendJournalLink:(DSJournal*)linkedJournal;
- (instancetype)appendJournalDescription:(DSJournal*)descriptedJournal;

- (NSString*)buildResponseWithDataProvider:(id<DSStoreDataProvidingProtocol>)dataProvider;

@end
