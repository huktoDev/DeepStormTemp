//
//  DSBaseMappingReporter.m
//  ReporterProject
//
//  Created by Alexandr Babenko on 21.07.16.
//  Copyright © 2016 Alexandr Babenko. All rights reserved.
//

#import "DSBaseMappingReporter.h"

@implementation DSBaseMappingReporter


#pragma mark - DSReporterMappingProtocol IMP (Initialization with MappingType)

@synthesize mappingType=_mappingType;

/// Помимо инициализации - назначает дефолтный маппер
- (instancetype)init{
    if(self = [super init]){
        
        BOOL isMappingSupported = [[self class] isSupportMapping];
        if(isMappingSupported){
            self.mappingType = DS_DEFAULT_MAPPING_TYPE;
        }else{
            self.mappingType = DSJournalObjectWithoutMapping;
        }
    }
    return self;
}

/// Инициализатор с типом маппинга
- (instancetype)initWithMappingType:(DSJournalObjectMapping)mappingType{
    if(self = [self init]){
        self.mappingType = mappingType;
    }
    return self;
}

/// По-умолчанию маппинг поддерживается
+ (BOOL)isSupportMapping{
    return YES;
}

- (void)setMappingType:(DSJournalObjectMapping)mappingType{
    
    BOOL isMappingSupported = [[self class] isSupportMapping];
    if(isMappingSupported){
        _mappingType = mappingType;
    }else{
        if(mappingType != DSJournalObjectWithoutMapping){
            NSAssert(NO, @"For this Reporter class %@ isSupportMapping return NO (mapping not supported). See %s", NSStringFromClass([self class]), __PRETTY_FUNCTION__);
        }else{
            _mappingType = mappingType;
        }
    }
}

@end
