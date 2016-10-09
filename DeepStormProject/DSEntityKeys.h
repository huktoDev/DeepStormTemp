//
//  DSEntityKeys.h
//  DeepStormProject
//
//  Created by Alexandr Babenko (HuktoDev) on 09.10.16.
//  Copyright © 2016 Alexandr Babenko. All rights reserved.
//

#ifndef DSEntityKeys_h
#define DSEntityKeys_h

/**
    @enum DSEntityKey
    @abstract Ключи для основных сущностей DeepStorm-а
 
    @constant DSEntityServiceKey
        Ключ для сущности сервиса
    @constant DSEntityJournalKey
        Ключ для сущности журнала
    @constant DSEntityRecordKey
        Ключ для сущности записи журнала
    @constant DSEntityErrorKey
        Ключ для сущности ошибки
 */
typedef NS_ENUM(NSUInteger, DSEntityKey) {
    DSEntityServiceKey,
    DSEntityJournalKey,
    DSEntityRecordKey,
    DSEntityErrorKey
};


#endif /* DSEntityKeys_h */
