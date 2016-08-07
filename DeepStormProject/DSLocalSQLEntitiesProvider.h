//
//  DSLocalSQLEntitiesProvider.h
//  ReporterProject
//
//  Created by Alexandr Babenko on 22.07.16.
//  Copyright © 2016 Alexandr Babenko. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NSEntityDescription;

@interface DSLocalSQLEntitiesProvider : NSObject

+ (NSString*)serviceEntityName;
+ (NSString*)journalEntityName;
+ (NSString*)recordEntityName;
+ (NSString*)errorEntityName;

+ (NSEntityDescription*)serviceEntity;
+ (NSEntityDescription*)journalEntity;
+ (NSEntityDescription*)recordEntity;
+ (NSEntityDescription*)errorEntity;

+ (void)setRelationsBetweenService:(NSEntityDescription*)serviceEntity andJournal:(NSEntityDescription*)journalEntity;
+ (void)setRelationsBetweenService:(NSEntityDescription*)serviceEntity andError:(NSEntityDescription*)errorEntity;
+ (void)setRelationsBetweenJournal:(NSEntityDescription*)journalEntity andRecord:(NSEntityDescription*)recordEntity;

@end
