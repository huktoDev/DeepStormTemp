//
//  TSVCLocationManager.h
//  Taxsee
//
//  Created by Admin on 15.06.15.
//  Copyright (c) 2015 LLC "Technologiya". All rights reserved.
//

#import <Foundation/Foundation.h>

@import UIKit;
#import "DeepStorm.h"

/**
    @constant TSVCNewLocationNotification
        Уведомление получения нового местоположения
    @constant TSVCStartUpdateLocationNotification
        Уведомление момента старта получения событий нового местоположения
    @constant TSVCStopUpdateLocationNotification
        Уведомление приходит, когда получения событий местоположения было остановлено
    @constant TSVCUserDetermineLocationServiceNotification
        Уведомление приходит, когда пользователь определяет свой статус использования сервиса геолокации
 */
extern NSString* const TSVCNewLocationNotification;
extern NSString* const TSVCStartUpdateLocationNotification;
extern NSString* const TSVCStopUpdateLocationNotification;
extern NSString* const TSVCUserDetermineLocationServiceNotification;

@import CoreLocation;

/**
    <hr>
    @class TSVCLocationManager
    @author HuktoDev
    @updated 08.04.2016
    @abstract Класс для работы с геолокационными системными сервисами
    @discussion TSVCLocationManager представляет собой обертку для взаимодействия с геолокацией, предоставляющий приложению единственный нужный ему (пока-что) метод -
    lastLocation (получение текущего местоположения)
    <hr>
 
    @note Возможности класса :
    <ul>
        <li> При первом входе пользователь получает алерт, предлагающий ему включить сервисы геолокации </li>
        <li> Если пользователь сразу не включил геолокацию - при каждом следующем запуске ему будет отображаться алерт, предлагающий включить взаимодействие с сервисом </li>
        <li> Класс поддерживает отправку некоторых важных своих событий через NSNotificationCenter </li>
        <li> Класс имеет свойства isActive и authorizationStatus для освещения своего текущего статуса сервиса </li>
        <li> Если сервисы геолокации не вклчены - из lastLocation прийдет nil </li>
        <li> Встроенное журналирование всех событий </li>
    </ul>
 
 */
@interface TSVCLocationManager : DSBaseLoggedService <CLLocationManagerDelegate, UIAlertViewDelegate> {
    
    @protected
    CLLocationManager *locationManager;
    
    @private
    CLLocation *lastLocation;
}

#pragma mark - initialization
+ (instancetype) sharedLocationManager;


#pragma mark - Dependencies 
// Инъекция зависимостей

- (void)injectDependencies;


#pragma mark - Preparation
// Подготовка сервиса к работе

- (void)prepareGeolocation;

    
    
#pragma mark - Geolocation States
// Переменные состояния сервиса

/// Выполняется получение событий геолокации, или нет
@property (assign, nonatomic) BOOL isActive;
/// Текущий статус работы геолокации
@property (assign, nonatomic) CLAuthorizationStatus authorizationStatus;


/// Определил ли пользователь свой статус с геолокацией, или нет
@property (assign, nonatomic) BOOL geolocationStatusDetermined;



#pragma mark - CENTRAL method class
// Основной метод класса - свойство, хранящее текущее местоположение устройства

- (CLLocation*) lastLocation;


#pragma mark - Change Status
// Изменить Статус сервисов геолокации

- (void)changeAuthorizationStatus:(CLAuthorizationStatus)newStatus;


@end



