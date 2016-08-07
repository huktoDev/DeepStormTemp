//
//  DSAdaptedDBError+Convertation.h
//  ReporterProject
//
//  Created by Alexandr Babenko on 22.07.16.
//  Copyright © 2016 Alexandr Babenko. All rights reserved.
//

#import "DSAdaptedDBError.h"

@interface DSAdaptedDBError (Convertation)

+ (instancetype)adaptedModelForError:(NSError*)convertationError fromBlankModel:(DSAdaptedDBError*)blankAdaptedError;
- (NSError*)convertToError;

@end
