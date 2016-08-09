//
//  DSTCPBaseServer.m
//  DeepStormProject
//
//  Created by Alexandr Babenko on 07.08.16.
//  Copyright © 2016 Alexandr Babenko. All rights reserved.
//

#import "DSTCPBaseServer.h"
#import "DSTCPConnection.h"

@implementation DSTCPBaseServer

- (instancetype)initWebServer{
    
    self = [super initWithConnectionClass:[DSTCPConnection class] port:8080];
    if(self){
        
    }
    return self;
}


@end
