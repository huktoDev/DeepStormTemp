//
//  DSTCPBaseServer.h
//  DeepStormProject
//
//  Created by Alexandr Babenko on 07.08.16.
//  Copyright © 2016 Alexandr Babenko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDNetworking.h"
#import "DSStoreDataProvidingProtocol.h"

@interface DSTCPBaseServer : GCDTCPServer

+ (instancetype)sharedWebServer;

- (void)updateWebServerDataWithDataProvider:(id<DSStoreDataProvidingProtocol>)dataProvider;

@end
