//
//  DSBaseMappingReporter.h
//  ReporterProject
//
//  Created by Alexandr Babenko on 21.07.16.
//  Copyright © 2016 Alexandr Babenko. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DSJournalMappingProtocol.h"

/**
    @protocol DSReporterMappingProtocol
    @author HuktoDev
    @updated  21.06.2016
    @abstract Протокол, который позволяет поддерживать разные виды маппинга для отправляемых данных
 */
@protocol DSReporterMappingProtocol <NSObject>

@required
- (instancetype)initWithMappingType:(DSJournalObjectMapping)mappingType;

@property (assign, nonatomic) DSJournalObjectMapping mappingType;

+ (BOOL)isSupportMapping;

@end


@interface DSBaseMappingReporter : NSObject <DSReporterMappingProtocol>

@end
