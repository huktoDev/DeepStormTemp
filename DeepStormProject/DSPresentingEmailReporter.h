////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/**
 *      DSPresentingEmailReporter.h
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
#import "DSBaseEmailReporter.h"

@class DSPresentingEmailReporter;
@compatibility_alias DSEmailReporter DSPresentingEmailReporter;

/**
    <hr>
    @class DSPresentingEmailReporter
    @author HuktoDev
    @updated 20.03.2016
    @abstract Класс-репортер, выполняющий отправку репортов на Email, используя стандартную форму отправки имейла
    @discussion
    При выполнении отправки письма - использует MFMailComposeViewController, который презентует модально сверху текущего контроллера.
    <hr>
 
    <h4> Возможности класса : </h4>
    <ol type="a">
        <li> Создание и отправка простого репорта для журнала DSJournal или сервиса DSBaseLoggedService </li>
        <li> Создание и отправка комплексного репорта по имейлу</li>
        <li> Возможность нзначить email-адрес назначения </li>
        <li> Определяет публичные методы для отправки почти любого имейла </li>
    </ol>
    <hr>
 */
@interface DSPresentingEmailReporter : DSBaseEmailReporter

@end



