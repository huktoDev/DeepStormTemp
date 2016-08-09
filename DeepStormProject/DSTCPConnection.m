//
//  DSTCPConnection.m
//  DeepStormProject
//
//  Created by Alexandr Babenko on 07.08.16.
//  Copyright © 2016 Alexandr Babenko. All rights reserved.
//

#import "DSTCPConnection.h"
#import "DSHTTPResponseBuilder.h"

@implementation DSTCPConnection


- (void)didOpen {
    [super didOpen];
    
    [self readDataAsynchronously:^(NSData* data) {
        if (data) {
            
            NSString *requestString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            
            
            CFHTTPMessageRef response = CFHTTPMessageCreateResponse(kCFAllocatorDefault, 200, NULL, kCFHTTPVersion1_1);
            CFHTTPMessageSetHeaderFieldValue(response, CFSTR("Connection"), CFSTR("Close"));
            CFHTTPMessageSetHeaderFieldValue(response, CFSTR("Server"), (__bridge CFStringRef)NSStringFromClass([self class]));
            
            NSData* data = CFBridgingRelease(CFHTTPMessageCopySerializedMessage(response));
            NSString *testResponse = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            
            //load html file
            
            NSString *framedHTMLFilePath = [[NSBundle mainBundle] pathForResource:@"deepStormIndexPage3" ofType:@"htm"];
            BOOL isExistBaseHtmlFile = (framedHTMLFilePath != nil);
            if(isExistBaseHtmlFile){
                
                NSString *responseString = [[NSString alloc] initWithContentsOfFile:framedHTMLFilePath encoding:NSUTF8StringEncoding error:nil];
                
                DSHTTPResponseBuilder *responseBuilder = [DSHTTPResponseBuilder responseBuilderWithHTMLPattern:responseString];
                responseString = [responseBuilder buildResponse];
                
                
                NSData* data = [responseString dataUsingEncoding:NSUTF8StringEncoding];
                if (data) {
                    [self writeDataAsynchronously:data completion:^(BOOL ok) {
                        [self close];
                    }];
                }
                
            }else{
                [self close];
            }
            
        } else {
            [self close];
        }
    }];
}

- (void)didClose {
    [super didClose];
}

@end
