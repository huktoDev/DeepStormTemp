//
//  DSAdaptedDBJournalRecord.h
//  ReporterProject
//
//  Created by Alexandr Babenko on 22.07.16.
//  Copyright © 2016 Alexandr Babenko. All rights reserved.
//

#import <CoreData/CoreData.h>
@import UIKit;

@class DSAdaptedDBJournal;

@interface DSAdaptedDBJournalRecord : NSManagedObject

@property (copy, nonatomic) NSNumber *number;
@property (copy, nonatomic) NSString *bodyText;
@property (copy, nonatomic) NSDate *date;
@property (copy, nonatomic) NSDictionary *additionalInfo;
@property (copy, nonatomic) NSNumber *logLevel;
@property (copy, nonatomic) NSString *logLevelDescription;
@property (copy, nonatomic) UIColor *presentColor;

@property (copy, nonatomic) DSAdaptedDBJournal *parentJournal;


@end
