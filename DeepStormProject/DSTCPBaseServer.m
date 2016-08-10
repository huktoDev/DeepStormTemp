//
//  DSTCPBaseServer.m
//  DeepStormProject
//
//  Created by Alexandr Babenko on 07.08.16.
//  Copyright © 2016 Alexandr Babenko. All rights reserved.
//

#import "DSTCPBaseServer.h"
#import "DSTCPConnection.h"
#import "DSHTTPResponseBuilder.h"


@interface DSTCPBaseServer ()

@property (strong, nonatomic) NSString *rawHTMLPattern;
@property (strong, nonatomic) NSString *processedHTML;
@property (strong, nonatomic) NSString *displayedHTML;

@property (strong, nonatomic) DSHTTPResponseBuilder *responseBuilder;


@end

@implementation DSTCPBaseServer

+ (instancetype)sharedWebServer{
    
    static DSTCPBaseServer *_sharedWebServer = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedWebServer = [[DSTCPBaseServer alloc] initDefaultWebServer];
    });
    return _sharedWebServer;
}

- (instancetype)initDefaultWebServer{
    
    NSString *framedHTMLFilePath = [[NSBundle mainBundle] pathForResource:@"deepStormIndexPage3" ofType:@"htm"];
    self = [self initWebServerPatternHTMLFile:framedHTMLFilePath];
    return self;
}

- (instancetype)initWebServerPatternHTMLFile:(NSString*)htmlFilePath{
    
    NSString *rawHTMLPattern = [[NSString alloc] initWithContentsOfFile:htmlFilePath encoding:NSUTF8StringEncoding error:nil];
    self = [self initWebServerWithHTMLPattern:rawHTMLPattern];
    return self;
}

- (instancetype)initWebServerWithHTMLPattern:(NSString*)rawHTML{
    
    self = [super initWithConnectionClass:[DSTCPConnection class] port:8080];
    if(self){
        self.rawHTMLPattern = [rawHTML copy];
        self.responseBuilder = [DSHTTPResponseBuilder responseBuilderWithHTMLPattern:rawHTML];
    }
    return self;
}

- (void)updateWebServerDataWithDataProvider:(id<DSStoreDataProvidingProtocol>)dataProvider{
    
    NSLog(@"OH YEEEAH");
    // update processed HTML
    
    self.processedHTML = [self.responseBuilder buildResponseWithDataProvider:dataProvider];
    // Update Page if needed
}


@end
