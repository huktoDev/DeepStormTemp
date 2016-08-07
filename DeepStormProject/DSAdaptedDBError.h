//
//  DSAdaptedDBError.h
//  ReporterProject
//
//  Created by Alexandr Babenko on 22.07.16.
//  Copyright © 2016 Alexandr Babenko. All rights reserved.
//

#import <CoreData/CoreData.h>
@class DSAdaptedDBService;

@interface DSAdaptedDBError : NSManagedObject

@property (copy, nonatomic) NSNumber *code;
@property (copy, nonatomic) NSString *domain;
@property (copy, nonatomic) NSString *localizedDescription;
@property (copy, nonatomic) NSNumber *serialNumber;

@property (copy, nonatomic) NSError *embeddedError;

@property (strong, nonatomic) DSAdaptedDBService *parentService;

@end
