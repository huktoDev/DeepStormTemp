//
//  DSLocalSQLEntitiesProvider.m
//  ReporterProject
//
//  Created by Alexandr Babenko on 22.07.16.
//  Copyright © 2016 Alexandr Babenko. All rights reserved.
//

#import "DSLocalSQLEntitiesProvider.h"
@import CoreData;

@implementation DSLocalSQLEntitiesProvider

#pragma mark - MAIN Dispatch Methods

/**
    @abstract Получить сущность CoreData для определенного типа
    @discussion
    Направляет в метод, соответствующий конкретному типу сущности
    @param entityKey        Тип сущности DeepStorm-а
    @return NSEntityDescription объект для CoreData, из которого будем формировать модель объекта в DB
 */
+ (NSEntityDescription*)entityForKey:(DSEntityKey)entityKey{
    
    switch (entityKey) {
        case DSEntityServiceKey:
            return [[self class] serviceEntity];
        case DSEntityJournalKey:
            return [[self class] journalEntity];
        case DSEntityRecordKey:
            return [[self class] recordEntity];
        case DSEntityErrorKey:
            return [[self class] errorEntity];
        default:{
            NSAssert(NO, @"Unknown entity key %lu. See %@ in %@", (unsigned long)entityKey, NSStringFromSelector(_cmd), NSStringFromClass([self class]));
            return nil;
        }
    }
}

/**
    @abstract Статический метод для установки сразу всех известных связей между сущностями
    @discussion
    Установка выполняется только единожды (больше для CoreData не нужно)
    Имеются 3 связи между сущностями :
    1) Сервис -> его внутренний журнал
    2) Сервис -> его внутренние ошибки
    3) Журнал -> составляющие его записи
 */
+ (void)setAllEntitiesRelations{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        [[self class] setRelationsBetweenEntitiesWithKeys:DSEntityServiceKey :DSEntityJournalKey];
        [[self class] setRelationsBetweenEntitiesWithKeys:DSEntityServiceKey :DSEntityErrorKey];
        [[self class] setRelationsBetweenEntitiesWithKeys:DSEntityJournalKey :DSEntityRecordKey];
    });
}

/**
    @abstract Настраивает CoreData отношения между двумя типами сущностей
    @discussion
    Алгоритм делится на несколько шагов :
    1) Определяются возможные связи между сущностями, и с каждой ассоциируется специальный селектор для установки связи
    2) Выполняется поиск последовательности из 2х сущностей (и тут порядок важен (родитель -> ребенок))
    3) Получаем селектор для установки связи, и 2 готовых NSEntityDescription
    4) Передаем управление конкретному связующему селектору
    @param firstEntityKey       Тип родительской сущности
    @param secondEntityKey       Тип дочерней сущности (вложенной)
 */
+ (void)setRelationsBetweenEntitiesWithKeys:(DSEntityKey)firstEntityKey :(DSEntityKey)secondEntityKey{
    
    NSArray<NSArray*> *possibleEntitiesSequence = @[@[@(DSEntityServiceKey), @(DSEntityJournalKey)],
                                                    @[@(DSEntityServiceKey), @(DSEntityErrorKey)],
                                                    @[@(DSEntityJournalKey), @(DSEntityRecordKey)]];
    
    NSArray<NSValue*> *relationsSelectors = @[[NSValue valueWithPointer:@selector(setRelationsBetweenService:andJournal:)],
                                              [NSValue valueWithPointer:@selector(setRelationsBetweenService:andError:)],
                                              [NSValue valueWithPointer:@selector(setRelationsBetweenJournal:andRecord:)]];
    
    NSUInteger indexValidRelation = 0;
    BOOL haveValidObtainedEntities = NO;
    for (NSArray<NSNumber*> *currentSequence in possibleEntitiesSequence) {
        DSEntityKey firstEntity = [[currentSequence firstObject] unsignedIntegerValue];
        DSEntityKey secondEntity = [[currentSequence lastObject] unsignedIntegerValue];
        
        BOOL areDontEqualEntities = (firstEntity != secondEntity);
        BOOL isFirstEntitiesSame = (firstEntity == firstEntityKey);
        BOOL isSecondEntitiesSame = (secondEntity == secondEntityKey);
        
        haveValidObtainedEntities = areDontEqualEntities && isFirstEntitiesSame && isSecondEntitiesSame;
        if(haveValidObtainedEntities){
            
            indexValidRelation = [possibleEntitiesSequence indexOfObject:currentSequence];
            break;
        }
    }
    
    if(! haveValidObtainedEntities){
        NSAssert(NO, @"Relation for this 2 Entity types wasn't found! Between %lu and %lu. See %s in %@", (unsigned long)firstEntityKey, (unsigned long)secondEntityKey, __PRETTY_FUNCTION__, NSStringFromClass([self class]));
        return;
    }
    
    SEL relationSelector = [relationsSelectors[indexValidRelation] pointerValue];
    
    NSEntityDescription *firstEntityImplementation = [[self class] entityForKey:firstEntityKey];
    NSEntityDescription *secondEntityImplementation = [[self class] entityForKey:secondEntityKey];
    
    BOOL isImplementedRelationSelector = [self respondsToSelector:relationSelector];
    if(isImplementedRelationSelector){
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [self performSelector:relationSelector withObject:firstEntityImplementation withObject:secondEntityImplementation];
#pragma clang diagnostic pop
        
    }else{
        NSAssert(NO, @"Implementation of Relation Selector %@ wasn't found! Link without setter method is impossible. See %s in %@", NSStringFromSelector(relationSelector), __PRETTY_FUNCTION__, NSStringFromClass([self class]));
    }
}


#pragma mark - Entities Names

+ (NSString*)serviceEntityName{
    return @"Service";
}

+ (NSString*)journalEntityName{
    return @"Journal";
}

+ (NSString*)recordEntityName{
    return @"JournalRecord";
}

+ (NSString*)errorEntityName{
    return @"Error";
}


#pragma mark - Enitites Provide

+ (NSEntityDescription*)serviceEntity{
    
    static NSEntityDescription *serviceEntity = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        NSAttributeDescription *classProperty = [NSAttributeDescription new];
        classProperty.name = @"serviceClass";
        classProperty.optional = NO;
        classProperty.transient = NO;
        classProperty.attributeType = NSStringAttributeType;
        classProperty.attributeValueClassName = @"NSString";
        classProperty.defaultValue = @"UnknownService";
        
        NSAttributeDescription *typeProperty = [NSAttributeDescription new];
        typeProperty.name = @"typeID";
        typeProperty.optional = YES;
        typeProperty.transient = NO;
        typeProperty.attributeType = NSInteger32AttributeType;
        typeProperty.attributeValueClassName = @"NSNumber";
        typeProperty.defaultValue = @(-1);
        
        NSAttributeDescription *workingModeProperty = [NSAttributeDescription new];
        workingModeProperty.name = @"workingMode";
        workingModeProperty.optional = NO;
        workingModeProperty.transient = NO;
        workingModeProperty.attributeType = NSStringAttributeType;
        workingModeProperty.attributeValueClassName = @"NSString";
        
        
        NSAttributeDescription *countErrorsProperty = [NSAttributeDescription new];
        countErrorsProperty.name = @"countEmergencyErrors";
        countErrorsProperty.optional = NO;
        countErrorsProperty.transient = NO;
        countErrorsProperty.attributeType = NSInteger32AttributeType;
        countErrorsProperty.attributeValueClassName = @"NSNumber";
        countErrorsProperty.defaultValue = @(0);
        
        
        serviceEntity = [NSEntityDescription new];
        
        serviceEntity.name = [[self class] serviceEntityName];
        serviceEntity.managedObjectClassName = @"DSAdaptedDBService";
        serviceEntity.abstract = NO;
        
        NSArray <NSAttributeDescription*> *servicePropertiesArray =
            @[classProperty,
              typeProperty,
              workingModeProperty,
              countErrorsProperty];
        
        serviceEntity.properties = servicePropertiesArray;
    });
    return serviceEntity;
}

+ (NSEntityDescription*)journalEntity{
    
    static NSEntityDescription *journalEntity = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        NSAttributeDescription *nameProperty = [NSAttributeDescription new];
        nameProperty.name = @"journalName";
        nameProperty.optional = YES;
        nameProperty.transient = NO;
        nameProperty.attributeType = NSStringAttributeType;
        nameProperty.attributeValueClassName = @"NSString";
        nameProperty.defaultValue = @"Unnamed Journal";
        
        NSAttributeDescription *classProperty = [NSAttributeDescription new];
        classProperty.name = @"journalClass";
        classProperty.optional = NO;
        classProperty.transient = NO;
        classProperty.attributeType = NSStringAttributeType;
        classProperty.attributeValueClassName = @"NSString";
        classProperty.defaultValue = @"UnknownJournal";
        
        NSAttributeDescription *currentCountProperty = [NSAttributeDescription new];
        currentCountProperty.name = @"currentCount";
        currentCountProperty.optional = NO;
        currentCountProperty.transient = NO;
        currentCountProperty.attributeType = NSInteger64AttributeType;
        currentCountProperty.attributeValueClassName = @"NSNumber";
        currentCountProperty.defaultValue = @(-1);
        
        NSAttributeDescription *maxCountProperty = [NSAttributeDescription new];
        maxCountProperty.name = @"maxCount";
        maxCountProperty.optional = NO;
        maxCountProperty.transient = NO;
        maxCountProperty.attributeType = NSInteger64AttributeType;
        maxCountProperty.attributeValueClassName = @"NSNumber";
        maxCountProperty.defaultValue = @(-1);
        
        NSAttributeDescription *outputStreamingStateProperty = [NSAttributeDescription new];
        outputStreamingStateProperty.name = @"outputStreamingState";
        outputStreamingStateProperty.optional = NO;
        outputStreamingStateProperty.transient = NO;
        outputStreamingStateProperty.attributeType = NSBooleanAttributeType;
        outputStreamingStateProperty.attributeValueClassName = @"NSNumber";
        outputStreamingStateProperty.defaultValue = @(NO);
        
        journalEntity = [NSEntityDescription new];
        
        journalEntity.name = [[self class] journalEntityName];
        journalEntity.managedObjectClassName = @"DSAdaptedDBJournal";
        journalEntity.abstract = NO;
        
        NSArray <NSAttributeDescription*> *journalPropertiesArray =
            @[nameProperty,
              classProperty,
              currentCountProperty,
              maxCountProperty,
              outputStreamingStateProperty];
        
        journalEntity.properties = journalPropertiesArray;
    });
    return journalEntity;
}

+ (NSEntityDescription*)recordEntity{
    
    static NSEntityDescription *journalRecordEntity = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        NSAttributeDescription *numberProperty = [NSAttributeDescription new];
        numberProperty.name = @"number";
        numberProperty.optional = NO;
        numberProperty.transient = NO;
        numberProperty.attributeType = NSInteger64AttributeType;
        numberProperty.attributeValueClassName = @"NSNumber";
        numberProperty.defaultValue = @(-1);
        
        NSAttributeDescription *bodyTextProperty = [NSAttributeDescription new];
        bodyTextProperty.name = @"bodyText";
        bodyTextProperty.optional = NO;
        bodyTextProperty.transient = NO;
        bodyTextProperty.attributeType = NSStringAttributeType;
        bodyTextProperty.attributeValueClassName = @"NSString";
        bodyTextProperty.defaultValue = @"";
        
        NSAttributeDescription *dateProperty = [NSAttributeDescription new];
        dateProperty.name = @"date";
        dateProperty.optional = YES;
        dateProperty.transient = NO;
        dateProperty.attributeType = NSDateAttributeType;
        dateProperty.attributeValueClassName = @"NSDate";
        dateProperty.defaultValue = nil;
        
        NSAttributeDescription *additionalInfoProperty = [NSAttributeDescription new];
        additionalInfoProperty.name = @"additionalInfo";
        additionalInfoProperty.optional = YES;
        additionalInfoProperty.transient = NO;
        additionalInfoProperty.attributeType = NSTransformableAttributeType;
        additionalInfoProperty.attributeValueClassName = @"NSDictionary";
        additionalInfoProperty.defaultValue = nil;
        
        NSAttributeDescription *logLevelProperty = [NSAttributeDescription new];
        logLevelProperty.name = @"logLevel";
        logLevelProperty.optional = NO;
        logLevelProperty.transient = NO;
        logLevelProperty.attributeType = NSInteger32AttributeType;
        logLevelProperty.attributeValueClassName = @"NSNumber";
        logLevelProperty.defaultValue = nil;
        
        NSAttributeDescription *logLevelDescProperty = [NSAttributeDescription new];
        logLevelDescProperty.name = @"logLevelDescription";
        logLevelDescProperty.optional = NO;
        logLevelDescProperty.transient = NO;
        logLevelDescProperty.attributeType = NSStringAttributeType;
        logLevelDescProperty.attributeValueClassName = @"NSString";
        logLevelDescProperty.defaultValue = @"UnknownLogLevel";
        
        NSAttributeDescription *presentColorProperty = [NSAttributeDescription new];
        presentColorProperty.name = @"presentColor";
        presentColorProperty.optional = YES;
        presentColorProperty.transient = NO;
        presentColorProperty.attributeType = NSTransformableAttributeType;
        presentColorProperty.attributeValueClassName = @"UIColor";
        presentColorProperty.defaultValue = nil;
        
        
        journalRecordEntity = [NSEntityDescription new];
        
        journalRecordEntity.name = [[self class] recordEntityName];
        journalRecordEntity.managedObjectClassName = @"DSAdaptedDBJournalRecord";
        journalRecordEntity.abstract = NO;
        
        NSArray <NSAttributeDescription*> *journalRecordPropertiesArray =
            @[numberProperty,
              bodyTextProperty,
              dateProperty,
              additionalInfoProperty,
              logLevelProperty,
              logLevelDescProperty,
              presentColorProperty];
        
        journalRecordEntity.properties = journalRecordPropertiesArray;
    });
    return journalRecordEntity;
}

+ (NSEntityDescription*)errorEntity{
    
    static NSEntityDescription *errorEntity = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        NSAttributeDescription *codeProperty = [NSAttributeDescription new];
        codeProperty.name = @"code";
        codeProperty.optional = NO;
        codeProperty.transient = NO;
        codeProperty.attributeType = NSInteger64AttributeType;
        codeProperty.attributeValueClassName = @"NSNumber";
        codeProperty.defaultValue = @(-1);
        
        NSAttributeDescription *domainProperty = [NSAttributeDescription new];
        domainProperty.name = @"domain";
        domainProperty.optional = NO;
        domainProperty.transient = NO;
        domainProperty.attributeType = NSStringAttributeType;
        domainProperty.attributeValueClassName = @"NSString";
        domainProperty.defaultValue = @"UnknownDomain";
        
        NSAttributeDescription *locDescriptionProperty = [NSAttributeDescription new];
        locDescriptionProperty.name = @"localizedDescription";
        locDescriptionProperty.optional = NO;
        locDescriptionProperty.transient = NO;
        locDescriptionProperty.attributeType = NSStringAttributeType;
        locDescriptionProperty.attributeValueClassName = @"NSString";
        locDescriptionProperty.defaultValue = @"";
        
        NSAttributeDescription *serialNumberProperty = [NSAttributeDescription new];
        serialNumberProperty.name = @"serialNumber";
        serialNumberProperty.optional = NO;
        serialNumberProperty.transient = NO;
        serialNumberProperty.attributeType = NSInteger64AttributeType;
        serialNumberProperty.attributeValueClassName = @"NSNumber";
        serialNumberProperty.defaultValue = @0;
        
        NSAttributeDescription *embeddedErrorProperty = [NSAttributeDescription new];
        embeddedErrorProperty.name = @"embeddedError";
        embeddedErrorProperty.optional = NO;
        embeddedErrorProperty.transient = NO;
        embeddedErrorProperty.attributeType = NSTransformableAttributeType;
        embeddedErrorProperty.attributeValueClassName = @"NSError";
        embeddedErrorProperty.defaultValue = nil;
        
        
        errorEntity = [NSEntityDescription new];
        
        errorEntity.name = [[self class] errorEntityName];
        errorEntity.managedObjectClassName = @"DSAdaptedDBError";
        errorEntity.abstract = NO;
        
        NSArray <NSAttributeDescription*> *errorPropertiesArray =
            @[codeProperty,
              domainProperty,
              locDescriptionProperty,
              serialNumberProperty,
              embeddedErrorProperty];
        
        errorEntity.properties = errorPropertiesArray;
    });
    return errorEntity;
}


#pragma mark - Relation Provide

+ (void)setRelationsBetweenService:(NSEntityDescription*)serviceEntity andJournal:(NSEntityDescription*)journalEntity{
    
    
    NSRelationshipDescription *journalRelation = [NSRelationshipDescription new];
    
    [journalRelation setName:@"journal"];
    [journalRelation setDestinationEntity:journalEntity];
    [journalRelation setMinCount:0];
    [journalRelation setMaxCount:1];
    [journalRelation setDeleteRule:NSCascadeDeleteRule];
    
    
    NSRelationshipDescription *parentServiceRelation = [NSRelationshipDescription new];
    
    [parentServiceRelation setName:@"parentService"];
    [parentServiceRelation setDestinationEntity:serviceEntity];
    [parentServiceRelation setMinCount:0];
    [parentServiceRelation setMaxCount:1];
    [parentServiceRelation setDeleteRule:NSNullifyDeleteRule];
    
    
    [journalRelation setInverseRelationship:parentServiceRelation];
    [parentServiceRelation setInverseRelationship:journalRelation];
    
    
    
    NSArray <NSPropertyDescription*> *serviceProperties = serviceEntity.properties;
    serviceProperties = [serviceProperties arrayByAddingObject:journalRelation];
    [serviceEntity setProperties:serviceProperties];
    
    NSArray <NSPropertyDescription*> *journalProperties = journalEntity.properties;
    journalProperties = [journalProperties arrayByAddingObject:parentServiceRelation];
    [journalEntity setProperties:journalProperties];
}

+ (void)setRelationsBetweenService:(NSEntityDescription*)serviceEntity andError:(NSEntityDescription*)errorEntity{
    
    NSRelationshipDescription *errorRelation = [NSRelationshipDescription new];
    
    [errorRelation setName:@"emergencyErrors"];
    [errorRelation setDestinationEntity:errorEntity];
    [errorRelation setMinCount:0];
    [errorRelation setMaxCount:0];
    [errorRelation setDeleteRule:NSCascadeDeleteRule];
    
    
    NSRelationshipDescription *parentServiceErrorRelation = [NSRelationshipDescription new];
    
    [parentServiceErrorRelation setName:@"parentService"];
    [parentServiceErrorRelation setDestinationEntity:serviceEntity];
    [parentServiceErrorRelation setMinCount:0];
    [parentServiceErrorRelation setMaxCount:1];
    [parentServiceErrorRelation setDeleteRule:NSNullifyDeleteRule];
    
    
    [errorRelation setInverseRelationship:parentServiceErrorRelation];
    [parentServiceErrorRelation setInverseRelationship:errorRelation];
    
    
    NSArray <NSPropertyDescription*> *serviceProperties = serviceEntity.properties;
    serviceProperties = [serviceProperties arrayByAddingObject:errorRelation];
    [serviceEntity setProperties:serviceProperties];
    
    NSArray <NSPropertyDescription*> *errorProperties = errorEntity.properties;
    errorProperties = [errorProperties arrayByAddingObject:parentServiceErrorRelation];
    [errorEntity setProperties:errorProperties];
}

+ (void)setRelationsBetweenJournal:(NSEntityDescription*)journalEntity andRecord:(NSEntityDescription*)recordEntity{
    
    
    NSRelationshipDescription *recordRelation = [NSRelationshipDescription new];
    
    [recordRelation setName:@"childRecords"];
    [recordRelation setDestinationEntity:recordEntity];
    [recordRelation setMinCount:0];
    [recordRelation setMaxCount:0];
    [recordRelation setDeleteRule:NSCascadeDeleteRule];
    
    
    NSRelationshipDescription *parentJournalRelation = [NSRelationshipDescription new];
    
    [parentJournalRelation setName:@"parentJournal"];
    [parentJournalRelation setDestinationEntity:journalEntity];
    [parentJournalRelation setMinCount:0];
    [parentJournalRelation setMaxCount:1];
    [parentJournalRelation setDeleteRule:NSNullifyDeleteRule];
    
    
    [recordRelation setInverseRelationship:parentJournalRelation];
    [parentJournalRelation setInverseRelationship:recordRelation];
    
    
    NSArray <NSPropertyDescription*> *journalProperties = journalEntity.properties;
    journalProperties = [journalProperties arrayByAddingObject:recordRelation];
    [journalEntity setProperties:journalProperties];
    
    NSArray <NSPropertyDescription*> *recordProperties = recordEntity.properties;
    recordProperties = [recordProperties arrayByAddingObject:parentJournalRelation];
    [recordEntity setProperties:recordProperties];
}



@end
