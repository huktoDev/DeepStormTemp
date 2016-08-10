//
//  DSWebServerReporter.h
//  DeepStormProject
//
//  Created by Alexandr Babenko on 10.08.16.
//  Copyright © 2016 Alexandr Babenko. All rights reserved.
//

#import "DSLocalSQLDatabaseReporter.h"

@interface DSWebServerReporter : DSLocalSQLDatabaseReporter

+ (DSWebServerReporter<DSStreamingEventFullProtocol>*)extendedWebServerReporter;

@property (assign, nonatomic, readonly) BOOL haveNewData;
- (void)invalidateServerData;

@end
