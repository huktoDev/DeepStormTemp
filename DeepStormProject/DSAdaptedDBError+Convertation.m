//
//  DSAdaptedDBError+Convertation.m
//  ReporterProject
//
//  Created by Alexandr Babenko on 22.07.16.
//  Copyright © 2016 Alexandr Babenko. All rights reserved.
//

#import "DSAdaptedDBError+Convertation.h"

@implementation DSAdaptedDBError (Convertation)

+ (instancetype)adaptedModelForError:(NSError*)convertationError fromBlankModel:(DSAdaptedDBError*)blankAdaptedError{
    
    DSAdaptedDBError *newAdaptedError = blankAdaptedError;
    
    newAdaptedError.code = @(convertationError.code);
    newAdaptedError.domain = convertationError.domain;
    newAdaptedError.localizedDescription = convertationError.localizedDescription;
    newAdaptedError.embeddedError = convertationError;
    
    return newAdaptedError;
}

- (NSError*)convertToError{
    
    NSError *newError = self.embeddedError;
    return newError;
}

@end
