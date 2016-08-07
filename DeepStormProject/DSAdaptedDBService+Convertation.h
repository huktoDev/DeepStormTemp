//
//  DSAdaptedDBService+Convertation.h
//  ReporterProject
//
//  Created by Alexandr Babenko on 22.07.16.
//  Copyright © 2016 Alexandr Babenko. All rights reserved.
//

#import "DSAdaptedDBService.h"

@class DSAdaptedObjectsFactory;
@class DSBaseLoggedService;

@interface DSAdaptedDBService (Convertation)

+ (instancetype)adaptedModelForService:(DSBaseLoggedService*)convertingService fromBlankModel:(DSAdaptedDBService*)blankAdaptedService andModelsFactory:(DSAdaptedObjectsFactory*)modelsFactory;
- (DSBaseLoggedService*)convertToService;

@end
