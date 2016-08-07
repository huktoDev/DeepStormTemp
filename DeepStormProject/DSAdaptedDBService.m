//
//  DSAdaptedDBService.m
//  ReporterProject
//
//  Created by Alexandr Babenko on 21.07.16.
//  Copyright © 2016 Alexandr Babenko. All rights reserved.
//

#import "DSAdaptedDBService.h"

#import "DSAdaptedDBJournal.h"
#import "DSAdaptedDBError.h"

@implementation DSAdaptedDBService

@dynamic serviceClass;
@dynamic typeID;
@dynamic workingMode;
@dynamic countEmergencyErrors;
@dynamic journal;
@dynamic emergencyErrors;

- (void)addEmergencyError:(DSAdaptedDBError*)newEmergencyError{
    
    [self.emergencyErrors addObject:newEmergencyError];
    newEmergencyError.parentService = self;
}

@end
