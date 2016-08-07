////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/**
 *      DSExternalJournalCloud.h
 *      DeepStorm Framework
 *
 *      Created by Alexandr Babenko on 27.02.16.
 *      Copyright © 2016 Alexandr Babenko. All rights reserved.
 *
 *      Licensed under the Apache License, Version 2.0 (the "License");
 *      you may not use this file except in compliance with the License.
 *      You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *      Unless required by applicable law or agreed to in writing, software
 *      distributed under the License is distributed on an "AS IS" BASIS,
 *      WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *      See the License for the specific language governing permissions and
 *      limitations under the License.
 */
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#import <Foundation/Foundation.h>
#import "DSJournal.h"


/**
    @class DSExternalJournalCloud
    @author HuktoDev
    @updated 26.03.2016
    @abstract Хранилище внешних журналов (не принадлежащих сервисам)
    @discussion
    Задача класса  - манипулировать набором журналов. Выдавать клиентам журналы по требованию. Связывать журнал с его названием.
    В системе имеется 2 типа журналов - журналы сервисов, и внешние журналы (external). Внешние журналы можно использовать  для любыз нужд. 
    Например, у каждого экрана может быть собственный журнал.
    Или у каждого роутера, или несколько контроллеров одного типа будут иметь общий журнал.
    Или иметь журнал для событий определенного типа
 
    Доступ к журналам лучше выполнять через DSLogger, или через макросы верхнего уровня. Однако, если нужен специальный менеджмент - лучше использовать их напрямую
 */
@interface DSExternalJournalCloud : NSObject{
    
    @private
    NSMutableDictionary <NSString*, DSJournal*> *journalsDictionary;
}

#pragma mark - Initialization
+ (instancetype)sharedCloud;


#pragma mark - CREATE Journal
// Содание журналов

- (void)createExternalJournals:(NSArray <NSString*> *)journalNames;
- (DSJournal*)createExternalJournalWithName:(NSString*)journalName;

#pragma mark - DELETE Journal
// Удаление журналов

- (BOOL)deleteJournalByName:(NSString*)journalName;


#pragma mark - RECIEVING Journal
// Получение журналов

- (DSJournal*)journalByName:(NSString*)journalName;
- (NSArray <NSString*> *)journalNamesList;


@end

