//
//  DSJournalRecordDescriptor.h
//  ReporterProject
//
//  Created by Alexandr Babenko on 20.03.16.
//  Copyright © 2016 Alexandr Babenko. All rights reserved.
//

#import <Foundation/Foundation.h>
@class DSJournalRecord;

@interface DSJournalRecordDescriptor : NSObject

- (NSString*)descriptionForRecord:(DSJournalRecord*)record;

@end
