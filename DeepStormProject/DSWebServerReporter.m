//
//  DSWebServerReporter.m
//  DeepStormProject
//
//  Created by Alexandr Babenko on 10.08.16.
//  Copyright © 2016 Alexandr Babenko. All rights reserved.
//

#import "DSWebServerReporter.h"
#import "DSTCPBaseServer.h"

@interface DSWebServerReporter ()

@property (assign, nonatomic, readwrite) BOOL haveNewData;
@property (strong, nonatomic, readwrite) DSTCPBaseServer *innerWebServer;

@end

@implementation DSWebServerReporter

+ (DSWebServerReporter<DSStreamingEventFullProtocol>*)extendedWebServerReporter{
    
    DSWebServerReporter<DSStreamingEventFullProtocol> *newExtendedWebReporter = [[self class] new];
    return newExtendedWebReporter;
}

- (instancetype)init{
    if(self = [super init]){
        self.innerWebServer = [DSTCPBaseServer sharedWebServer];
    }
    return self;
}

- (void)invalidateServerData{
    self.haveNewData = YES;
}

- (void)updateDataIfNeeded{
    
}

- (BOOL)executeStreamingEvent:(id<DSStreamingEventProtocol>)streamingEvent{
    BOOL isDatabaseSuccessStored = [super executeStreamingEvent:streamingEvent];
    if(isDatabaseSuccessStored){
        // send data to WebServer
        [self.innerWebServer updateWebServerDataWithDataProvider:self.localDB];
        return YES;
    }
    return NO;
}

@end
