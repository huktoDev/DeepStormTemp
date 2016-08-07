//
//  DSAdaptedDBJournal+Convertation.h
//  ReporterProject
//
//  Created by Alexandr Babenko on 22.07.16.
//  Copyright © 2016 Alexandr Babenko. All rights reserved.
//

#import "DSAdaptedDBJournal.h"

@class DSJournal;
@class DSAdaptedObjectsFactory;

@interface DSAdaptedDBJournal (Convertation)

+ (instancetype)adaptedModelForJournal:(DSJournal*)convertingJournal fromBlankModel:(DSAdaptedDBJournal*)blankAdaptedJournal andModelsFactory:(DSAdaptedObjectsFactory*)modelsFactory;
- (DSJournal*)convertToJournal;


@end
