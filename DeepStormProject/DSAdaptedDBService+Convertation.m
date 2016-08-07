//
//  DSAdaptedDBService+Convertation.m
//  ReporterProject
//
//  Created by Alexandr Babenko on 22.07.16.
//  Copyright © 2016 Alexandr Babenko. All rights reserved.
//

#import "DSAdaptedDBService+Convertation.h"
#import "DSBaseLoggedService.h"

#import "DSJournal.h"
#import "DSAdaptedDBJournal.h"
#import "DSAdaptedDBJournal+Convertation.h"
#import "DSAdaptedDBError.h"

#import "DSAdaptedObjectsFactory.h"

@implementation DSAdaptedDBService (Convertation)

//TODO: withContext:
//Adapted Error Entities
// Error restore values + workingType restore values + error & workingType description

+ (instancetype)adaptedModelForService:(DSBaseLoggedService*)convertingService fromBlankModel:(DSAdaptedDBService*)blankAdaptedService andModelsFactory:(DSAdaptedObjectsFactory*)modelsFactory{
    
    DSAdaptedDBService *newAdaptedService = blankAdaptedService;
    
    newAdaptedService.serviceClass = NSStringFromClass([convertingService class]);
    newAdaptedService.typeID = convertingService.serviceType;
    newAdaptedService.workingMode = serviceWorkingModeDescription(convertingService.workingMode);
    
    DSAdaptedDBJournal *serviceAdaptedJournal = [modelsFactory adaptedModelFromJournal:convertingService.logJournal];
    newAdaptedService.journal = serviceAdaptedJournal;
    
    NSUInteger errorSerialIndex = 0;
    for (NSError *currentEmergencyError in convertingService.emergencySituationsErrors) {
        
        DSAdaptedDBError *newAdaptedError = [modelsFactory adaptedModelFromError:currentEmergencyError];
        newAdaptedError.serialNumber = @(errorSerialIndex);
        
        [newAdaptedService addEmergencyError:newAdaptedError];
        
        errorSerialIndex ++;
    }
    newAdaptedService.countEmergencyErrors = @(convertingService.emergencySituationsErrors.count);

    return newAdaptedService;
}

- (DSBaseLoggedService*)convertToService{
    
    DSBaseLoggedService *newService = [NSClassFromString(self.serviceClass) new];
    
    newService.serviceType = self.typeID;
    
    DSJournal *attachmentJournal = [self.journal convertToJournal];
    newService.logJournal = attachmentJournal;
    
    return newService;
}

@end
