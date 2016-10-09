//
//  DSLocalSQLEntitiesProvider.h
//  ReporterProject
//
//  Created by Alexandr Babenko on 22.07.16.
//  Copyright © 2016 Alexandr Babenko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DSEntityKeys.h"

@class NSEntityDescription;


/**
    @class DSLocalSQLEntitiesProvider
    @author HuktoDev
    @updated 28.08.2016
    @abstract Вспомогательный статический класс, предоставляющий набор сущностей для CoreData
    @discussion
    Является заменой классической модели данных (DataModel). Предоставляет 4 основные сущности БД, и несколько правил взаимодействия между ними.
    @note
    Класс является чисто  статическим
 */
@interface DSLocalSQLEntitiesProvider : NSObject

+ (NSEntityDescription*)entityForKey:(DSEntityKey)entityKey;
+ (void)setAllEntitiesRelations;

@end
