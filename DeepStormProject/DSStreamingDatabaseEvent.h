//
//  DSStreamingDatabaseEvent.h
//  ReporterProject
//
//  Created by Alexandr Babenko on 21.07.16.
//  Copyright © 2016 Alexandr Babenko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DSSendingEventInterfaces.h"

typedef NS_ENUM(NSUInteger, DSStreamingDatabaseEventType) {
    DSStreamingDatabaseInsertEvent,
    DSStreamingDatabaseUpdateEvent,
    DSStreamingDatabaseDeleteEvent,
};

@interface DSStreamingDatabaseEvent : NSObject <DSStreamingEventProtocol>

@property (assign, nonatomic) DSStreamingDatabaseEventType eventType;
@property (strong, nonatomic) id<DSEventConvertibleEntity> streamingEntity;

@end
