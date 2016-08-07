//
//  DSAdaptedDBJournal.h
//  ReporterProject
//
//  Created by Alexandr Babenko on 21.07.16.
//  Copyright © 2016 Alexandr Babenko. All rights reserved.
//

#import <CoreData/CoreData.h>
@class DSAdaptedDBService;

@interface DSAdaptedDBJournal : NSManagedObject

@property (copy, nonatomic) NSString *journalName;
@property (copy, nonatomic) NSString *journalClass;
@property (copy, nonatomic) NSNumber *currentCount;
@property (copy, nonatomic) NSNumber *maxCount;
@property (copy, nonatomic) NSNumber *outputStreamingState;

@property (strong, nonatomic) DSAdaptedDBService *parentService;
@property (strong, nonatomic) NSMutableSet *childRecords;

@end
