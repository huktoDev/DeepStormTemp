//
//  DSAdaptedDBService.h
//  ReporterProject
//
//  Created by Alexandr Babenko on 21.07.16.
//  Copyright © 2016 Alexandr Babenko. All rights reserved.
//

#import <CoreData/CoreData.h>
@class DSAdaptedDBJournal, DSAdaptedDBError;

@interface DSAdaptedDBService : NSManagedObject

@property (copy, nonatomic) NSString *serviceClass;
@property (copy, nonatomic) NSNumber *typeID;
@property (copy, nonatomic) NSString *workingMode;
@property (copy, nonatomic) NSNumber *countEmergencyErrors;

@property (strong, nonatomic) DSAdaptedDBJournal *journal;
@property (strong, nonatomic) NSMutableSet <DSAdaptedDBError*> *emergencyErrors;

// Назначенный сэттер
- (void)addEmergencyError:(DSAdaptedDBError*)newEmergencyError;

@end
