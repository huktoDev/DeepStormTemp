//
//  DSEntityProtocol.h
//  DeepStormProject
//
//  Created by Alexandr Babenko (HuktoDev) on 09.10.16.
//  Copyright © 2016 Alexandr Babenko. All rights reserved.
//

#ifndef DSEntityProtocol_h
#define DSEntityProtocol_h

#import "DSEntityKeys.h"

#import "DSJournal.h"
#import "DSBaseLoggedService.h"


/**
    @protocol DSEntityProtocol
    @author HuktoDev
    @updated 09.10.2016
    @abstract Основной протокол для всех базовых сущностей DeepStorm-а
 */
@protocol DSEntityProtocol <NSObject>

@optional
@property (assign, nonatomic, readonly) DSEntityKey entityKey;

@end


/**+++++++++++++++++++++++++++++++++++++++++++++
    ++++++ Сущности, поддерживваемые протокол ++++++
    +++++++++++++++++++++++++++++++++++++++++++++*/

@interface DSJournal () <DSEntityProtocol>
@end

@interface DSBaseLoggedService () <DSEntityProtocol>
@end

@interface DSJournalRecord () <DSEntityProtocol>
@end

@interface NSError () <DSEntityProtocol>
@end

////////////////////////////////////////////////////////////////////////////////////

#endif /* DSEntityProtocol_h */
