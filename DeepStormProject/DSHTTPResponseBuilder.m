//
//  DSHTTPResponseBuilder.m
//  DeepStormProject
//
//  Created by Alexandr Babenko on 10.08.16.
//  Copyright © 2016 Alexandr Babenko. All rights reserved.
//

#import "DSHTTPResponseBuilder.h"
#import "DSStoreDataProvidingProtocol.h"

#define DS_REG_EXP_SAFE_CREATE(futureRegExpObject, patternString) futureRegExpObject = [NSRegularExpression regularExpressionWithPattern:patternString options:0 error:&regExpError]; \
NSAssert((regExpError == nil), @"Regular Expression %@ fail creation with Error : %@.\n%s in %@", patternString, [regExpError localizedDescription], __PRETTY_FUNCTION__, NSStringFromClass([self class]));


typedef NS_ENUM(NSUInteger, DSHTTPDeepStormKeyTags) {
    DSHTTPDeepStormKeyTagServiceLink,
    DSHTTPDeepStormKeyTagServiceDescription,
    DSHTTPDeepStormKeyTagServiceDisplay,
    DSHTTPDeepStormKeyTagJournalLink,
    DSHTTPDeepStormKeyTagJournalDescription,
    DSHTTPDeepStormKeyTagJournalDisplay,
    DSHTTPDeepStormKeyTagRecordDisplay
};


@interface DSHTMLPatternCheckingResult : NSTextCheckingResult

+ (instancetype)patternCheckingResultFromParentResult:(NSTextCheckingResult*)textCheckResult withSearchString:(NSString*)baseSearchString;

@property (assign, nonatomic) NSRange patternRange;
@property (assign, nonatomic) DSHTTPDeepStormKeyTags patternTagType;

@property (copy, nonatomic) NSString *keyString;
- (NSDictionary<NSString*, NSString*>*)getChildTagsInfo;

@end

@implementation DSHTMLPatternCheckingResult

+ (instancetype)patternCheckingResultFromParentResult:(NSTextCheckingResult*)textCheckResult withSearchString:(NSString*)baseSearchString{
    
    DSHTMLPatternCheckingResult *newPatternResult = [DSHTMLPatternCheckingResult new];
    newPatternResult.patternRange = textCheckResult.range;
    newPatternResult.keyString = [baseSearchString substringWithRange:newPatternResult.patternRange];
    
    return newPatternResult;
}

- (NSDictionary<NSString*, NSString*>*)getChildTagsInfo{
    return nil;
}

@end



@implementation DSHTTPResponseBuilder{
    
    @private
    NSString *_rawHTMLText;
    NSArray<DSHTMLPatternCheckingResult*> *_collectedKeyTagsArray;
}

+ (instancetype)responseBuilderWithHTMLPattern:(NSString*)htmlPreparedPattern{
    
    DSHTTPResponseBuilder *baseResponseBuilder = [[DSHTTPResponseBuilder alloc] initWithHTMLPattern:htmlPreparedPattern];
    return baseResponseBuilder;
}

+ (instancetype)responseBuilderWithHTMLBaseFrame:(NSString*)htmlFilePath{
    
    BOOL isExistBaseHTMLFile = [[NSFileManager defaultManager] fileExistsAtPath:htmlFilePath];
    if(! isExistBaseHTMLFile){
        return nil;
    }
    NSString *htmlLoadedPattern = [[NSString alloc] initWithContentsOfFile:htmlFilePath encoding:NSUTF8StringEncoding error:nil];
    
    DSHTTPResponseBuilder *baseResponseBuilder = [[DSHTTPResponseBuilder alloc] initWithHTMLPattern:htmlLoadedPattern];
    return baseResponseBuilder;
}

- (instancetype)initWithHTMLPattern:(NSString*)htmlPattern{
    
    if(self = [super init]){
        
        _rawHTMLText = [htmlPattern copy];
        NSDictionary<NSNumber*, NSRegularExpression*> *patternKeyTags = [[self class] patternDeepStormKeyTags];
        _collectedKeyTagsArray = [self searchAllKeyTagsInRawHTMLText:htmlPattern byTagPatterns:patternKeyTags];
        
        NSLog(@"");
        
        // Load specific Keys from HTML {{  }}
        
        // {{ SVC_LINK name="" alias="" }}
        // {{ SVC_DESC }}
        // {{ JRN_LINK name="" alias="" }}
        // {{ JRN_DESC }}
        
        // {{ SVC_DISPLAY name="" }}
        // {{ JRN_DISPLAY name="" }}
        
        // {{ REC_DISPLAY jrnName="" recNumber="" }}
        
        
        
        // search Key Tags
        // valid Key Tag
    }
    return self;
}

+ (NSDictionary<NSNumber*, NSRegularExpression*>*)patternDeepStormKeyTags{
    
    static NSDictionary <NSNumber*, NSRegularExpression*> *keyHTMLPatternsDictionary = nil;
    
    static NSRegularExpression *serviceLinkRegExp = nil;
    static NSRegularExpression *serviceDescRegExp = nil;
    static NSRegularExpression *journalLinkRegExp = nil;
    static NSRegularExpression *journalDescRegExp = nil;
    static NSRegularExpression *serviceDisplayRegExp = nil;
    static NSRegularExpression *journalDisplayRegExp = nil;
    static NSRegularExpression *recordDisplayRegExp = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        NSError *regExpError = nil;
        
        DS_REG_EXP_SAFE_CREATE(serviceLinkRegExp, @"\\{\\{( )?SVC_LINK name=\"\\w{2,64}\" alias=\".{2,64}\"( )?\\}\\}");
        DS_REG_EXP_SAFE_CREATE(serviceDescRegExp, @"\\{\\{( )?SVC_DESC( )?\\}\\}");
        DS_REG_EXP_SAFE_CREATE(serviceDisplayRegExp, @"\\{\\{( )?SVC_DISPLAY name=\"\\w{2,64}\"( )?\\}\\}");
        
        DS_REG_EXP_SAFE_CREATE(journalLinkRegExp, @"\\{\\{( )?JRN_LINK name=\"\\w{2,64}\" alias=\".{2,64}\"( )?\\}\\}");
        DS_REG_EXP_SAFE_CREATE(journalDescRegExp, @"\\{\\{( )?JRN_DESC( )?\\}\\}");
        DS_REG_EXP_SAFE_CREATE(journalDisplayRegExp, @"\\{\\{( )?JRN_DISPLAY name=\"\\w{2,64}\"( )?\\}\\}");
        
        DS_REG_EXP_SAFE_CREATE(recordDisplayRegExp, @"\\{\\{( )?REC_DISPLAY jrnName=\"\\w{2,64}\" recNumber=\"\\d{1,5}\"( )?\\}\\}");
        
        keyHTMLPatternsDictionary =
        @{@(DSHTTPDeepStormKeyTagServiceLink)           :   serviceLinkRegExp,
          @(DSHTTPDeepStormKeyTagServiceDescription)    :   serviceDescRegExp,
          @(DSHTTPDeepStormKeyTagServiceDisplay)        :   serviceDisplayRegExp,
          @(DSHTTPDeepStormKeyTagJournalLink)           :   journalLinkRegExp,
          @(DSHTTPDeepStormKeyTagJournalDescription)    :   journalDescRegExp,
          @(DSHTTPDeepStormKeyTagJournalDisplay)        :   journalDisplayRegExp,
          @(DSHTTPDeepStormKeyTagRecordDisplay)         :   recordDisplayRegExp};
    });
    
    return keyHTMLPatternsDictionary;
}

- (NSArray<DSHTMLPatternCheckingResult*>*)searchAllKeyTagsInRawHTMLText:(NSString*)rawHTML byTagPatterns:(NSDictionary<NSNumber*, NSRegularExpression*>*)keyTagPatterns{
    
    NSMutableArray *keyTagsArray = [NSMutableArray new];
    for (NSNumber *patternTagWrappedID in [keyTagPatterns allKeys]) {
        
        DSHTTPDeepStormKeyTags patternTagType = [patternTagWrappedID unsignedIntegerValue];
        NSRegularExpression *relatedPatternRegExp = [keyTagPatterns objectForKey:patternTagWrappedID];
        
        [relatedPatternRegExp enumerateMatchesInString:rawHTML options:0 range:NSMakeRange(0, rawHTML.length) usingBlock:^(NSTextCheckingResult * __nullable result, NSMatchingFlags flags, BOOL *stop){
            
            DSHTMLPatternCheckingResult *convertedResult = [DSHTMLPatternCheckingResult patternCheckingResultFromParentResult:result withSearchString:rawHTML];
            convertedResult.patternTagType = patternTagType;
            
            [keyTagsArray addObject:convertedResult];
        }];
    }
    return [NSArray arrayWithArray:keyTagsArray];
}

- (NSString*)processAndFillRawHTML:(NSString*)rawHtml withKeyTags:(NSArray<DSHTMLPatternCheckingResult*>*)keyTagsArray{
    
    NSMutableString *processedHTML = [rawHtml mutableCopy];
    for (DSHTMLPatternCheckingResult *keyTagPatternResult in keyTagsArray) {
        
        DSHTTPDeepStormKeyTags patternTagType = keyTagPatternResult.patternTagType;
        switch (patternTagType) {
            case DSHTTPDeepStormKeyTagServiceLink:{
                // Get Service Info from DB
                // Replace on Link
                NSString *replacingPatternString = @"<a href=\"/link/to/page2\">Fuck Service</a>";
                [processedHTML replaceCharactersInRange:keyTagPatternResult.patternRange withString:replacingPatternString];
                break;
            }case DSHTTPDeepStormKeyTagJournalLink:{
                // Get Journal Info from DB
                // Replace on Link
                NSString *replacingPatternString = @"<a href=\"/link/to/page2\">Fuck Journal</a>";
                [processedHTML replaceCharactersInRange:keyTagPatternResult.patternRange withString:replacingPatternString];
                break;
                
            }default:
                break;
        }
    }
    return processedHTML;
}

- (NSString*)buildResponseWithDataProvider:(id<DSStoreDataProvidingProtocol>)dataProvider{
    return [self processAndFillRawHTML:_rawHTMLText withKeyTags:_collectedKeyTagsArray];
}

@end
