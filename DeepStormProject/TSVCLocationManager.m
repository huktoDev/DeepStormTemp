//
//  TSVCLocationManager.m
//  Taxsee
//
//  Created by Admin on 15.06.15.
//  Copyright (c) 2015 LLC "Technologiya". All rights reserved.
//

#import "TSVCLocationManager.h"

NSString* const TSVCNewLocationNotification = @"NewLocation";
NSString* const TSVCStartUpdateLocationNotification = @"StartUpdateLocation";
NSString* const TSVCStopUpdateLocationNotification = @"StopUpdateLocation";
NSString* const TSVCUserDetermineLocationServiceNotification = @"UserDetermineLocationService";

@implementation TSVCLocationManager{
    
    NSTimer *determinationTimer;
    
    UIApplication *application;
    NSNotificationCenter *notifCenter;
}


#pragma mark - initialization

+ (instancetype) sharedLocationManager{
    
    static TSVCLocationManager *activeLocationManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        activeLocationManager = [TSVCLocationManager new];
    });
    return activeLocationManager;
}


#pragma mark - Dependencies 

/// Инъекция зависимостей
- (void)injectDependencies{
    
    application = [UIApplication sharedApplication];
    notifCenter = [NSNotificationCenter defaultCenter];
}


#pragma mark - Preparation

/**
    @abstract Подготавливает геолокацию к использованию
    @discussion
    Выполняет конфигурирование сервиса :
 
    - Если геолоакционные системные сервисы отсутствуют, или заблокированы - не выполнять конфигурирование (статус неактивен)
 
    - Если нет доступа к сервисам, или отказано в доступе - попытаться вывести алерт геолокации (с запросом)
 
    - Если статус получения сообщений геолокации не определен - запросить определение статуса (метод фреймворка)
 
    - Если получение событий уже определено, и разрешено - конфигурировать и начать получение событий геолокации
 
    - Если требуется - отобразить алерт геолокации (запрашивающий и ведущий к настройкам геолокации)
 */
- (void)prepareGeolocation{
    
    DSJOURNALLING_LOG(@"%@ Start Initialization", NSStringFromClass([self class]));
    
    determinationTimer = [NSTimer scheduledTimerWithTimeInterval:10.f target:self selector:@selector(geolocationDeterminationTimerFire:) userInfo:nil repeats:NO];
    
    self.authorizationStatus = [CLLocationManager authorizationStatus];
    self.isActive = NO;
    
    // Если сервисы недоступны
    if( [self isServicesDisabledWithMessage]){
        return;
    }
    
    DSJOURNALLING_LOG(@"Location services are enabled on Device");
    
    if (self.authorizationStatus == kCLAuthorizationStatusDenied){
        
        DSJOURNALLING_LOG(@"Location services are blocked by the user");
        
    }else if(self.authorizationStatus == kCLAuthorizationStatusRestricted){
        
        DSJOURNALLING_LOG(@"Application is not authorized to use location services");
        
    }else if (self.authorizationStatus == kCLAuthorizationStatusNotDetermined){
        // Определить пользовательский статус
        
        DSJOURNALLING_LOG(@"Start determine User Geolocation Status");
        [self determineUserStatus];
    }
    else if(self.authorizationStatus == kCLAuthorizationStatusAuthorizedAlways || self.authorizationStatus == kCLAuthorizationStatusAuthorizedWhenInUse || self.authorizationStatus == kCLAuthorizationStatusAuthorized){
        
        // Если приложение авторизовано в сервисах тем, или иным способом
        DSJOURNALLING_LOG(@"Location services are enabled");
        
        [self configAndStartUpdatingLocation];
        self.geolocationStatusDetermined = YES;
        return;
    }
    
    // Если у пользователя отключена геолокация - предложить включить ( с переходом в settings )
    [self geolocationAlertIfNeeded];
}

#pragma mark - Change Status

/**
    @abstract Изменяет статус авторизации в сервисах геолокации
    @discussion
    Когда изменяется статус авторизации в сервисах геолокации - сюда требуется передать статус, чтобы в приложении изменения вступили в силу
 
    @note Вызывается каждый раз при выходе из бэкграунда
    
    @param newStatus Новый статус авторизации
 */
- (void)changeAuthorizationStatus:(CLAuthorizationStatus)newStatus{
    
    [self locationManager:locationManager didChangeAuthorizationStatus:newStatus];
}

- (void)setGeolocationStatusDetermined:(BOOL)geolocationStatusDetermined{
    _geolocationStatusDetermined = geolocationStatusDetermined;
    [notifCenter postNotificationName:TSVCUserDetermineLocationServiceNotification object:@(_geolocationStatusDetermined)];
}

- (void)geolocationDeterminationTimerFire:(NSTimer*)determTimer{
    self.geolocationStatusDetermined = YES;
    
    if([determTimer isValid]){
        [determTimer invalidate];
        determTimer = nil;
    }
}

#pragma mark - CLLocationManagerDelegate methods

/// При изменении авторизационного статуса
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    
    DSJOURNALLING_LOG(@"Authorization status Core Location Manager changed to %i", status);
    self.authorizationStatus = [CLLocationManager authorizationStatus];
    
    //если в сервисы авторизуется - настроить менеджер
    if( status == kCLAuthorizationStatusAuthorizedAlways || status == kCLAuthorizationStatusAuthorizedWhenInUse || status == kCLAuthorizationStatusAuthorized){
        
        [self configAndStartUpdatingLocation];
        self.geolocationStatusDetermined = YES;
    } //если из сервисов выходит - прекратить обновление событий геолокации
    else if( status != kCLAuthorizationStatusNotDetermined){
        [self stopUpdatingLocation];
        self.geolocationStatusDetermined = YES;
    }
}

/// При получении событий геолокации (координат)
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    
    // Если получено новое, отличающегося от имеющегося, местополжение устройства - записать его в lastlocation переменную
    CLLocation *newLocation = (CLLocation*)[locations lastObject];
    if( lastLocation.coordinate.latitude != newLocation.coordinate.latitude ||
       lastLocation.coordinate.longitude != newLocation.coordinate.longitude){
        
        lastLocation = [locations lastObject];
        DSJOURNALLING_LOG(@"+++++++++++++++++++++++++++++++++\nLocation Coordinate are change.\nNew Location : \nlatitude %.12f\nlongitude %.12f\naccuracy : %.12f\n+++++++++++++++++++++++++++++++++", lastLocation.coordinate.latitude, lastLocation.coordinate.longitude, lastLocation.horizontalAccuracy);
        
        [notifCenter postNotificationName:TSVCNewLocationNotification object: [lastLocation copy]];
    }else{
        
        DSJOURNALLING_LOG(@"Location Coordinate are not changed");
    }
}

#pragma mark - CENTRAL method class

/// Акцессор к последнему местположению пользователя (используется сетевым ядром при добавлении местоположения к запросу)
- (CLLocation*)lastLocation{
    @synchronized(lastLocation){
        
        CLLocation *currentLocation = [lastLocation copy];
        return currentLocation;
    }
}

#pragma mark - UIAlertViewDelegate methods

/// Выполняет действия, в зависимости от нажатой пользователем кнопки алерта
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if(buttonIndex == 1){
        NSURL *locationSettingsURL = [self locationSettingsURL];
        
        DSJOURNALLING_LOG(@"Transition to Settings URL %@", locationSettingsURL);
        if(locationSettingsURL){
            [application openURL:locationSettingsURL];
        }
    }else{
        DSJOURNALLING_LOG(@"User discard using Location Services");
    }
    self.geolocationStatusDetermined = YES;
}

#pragma mark - User & Locations actions

/** 
    @abstract
    Проверка, способно ли устройство получать данные геолокации/включены ли сервисы 
    @return Текущее состояние сервисов геолокации (YES - включены)
 */
-(BOOL)isServicesDisabledWithMessage{
    
    if( ![CLLocationManager locationServicesEnabled]){
        
        DSJOURNALLING_LOG(@"Location services are disabled");
        //[TZUtility showError:TZLocalizedString(@"GeolocationServiceDisabled", @"") delegate:nil];
        return YES;
    }
    return NO;
}

/**
    @abstract Определяет пользовательский геолокационный статус
    @discussion 
    
    @note Для пользователей с iOS 8+ и ниже - выполняет разные действия
 
    Вызывается, когда пользовательский статус не определен, и его требуется определить (например, при первом входе в приложение)
 
    Если статус еще не определен (пользователь входит первый раз) - если прошивка выше 8.0 - запросить авторизацию явно, иначе - неявно через startUpdatingLocation
 */
-(void)determineUserStatus{
    
    DSJOURNALLING_LOG(@"Will show a dialog requesting permission for Location Service");
    
    locationManager = [CLLocationManager new];
    locationManager.delegate = self;
    
    /*
    if ([TZUtility getVersionOS] >= 8.f && [locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]){
        [locationManager requestWhenInUseAuthorization];
    }else{
        [locationManager startUpdatingLocation];
        
        [notifCenter postNotificationName:TSVCStartUpdateLocationNotification object: locationManager];
        self.geolocationStatusDetermined = YES;
    }
     */
}

/**
    @abstract Конфигурирует сервис и начинает сбор событий геолокации
    @discussion
    Конфигурирует или переконфигурирует, лучшей возможной точностью сервиса геолокации. Задает делегата и т.п.
 
    @note Наилучшая возможная точность может использовать слишком много заряда батареи
 */
-(void)configAndStartUpdatingLocation{
    
    if([self isServicesDisabledWithMessage]){
        return;
    }
    
    DSJOURNALLING_LOG(@"Configuration...");
    
    if(! locationManager){
        locationManager = [CLLocationManager new];
    }
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    self.isActive = YES;
    [locationManager startUpdatingLocation];
    
    DSJOURNALLING_LOG(@"Start Updating Location");
    
    [notifCenter postNotificationName:TSVCStartUpdateLocationNotification object: locationManager];
}

/**
    @abstract Прекращает сбор событий геолокации
    @discussion
    Устанавливает свойство сервиса isActive в NO, обнуляет текущее местоположение
 */
- (void)stopUpdatingLocation{
    
    if([self isServicesDisabledWithMessage]){
        return;
    }
    
    if(locationManager){
        self.isActive = NO;
        [locationManager stopUpdatingLocation];
        
        DSJOURNALLING_LOG(@"Stop Updating Location");
        [notifCenter postNotificationName:TSVCStopUpdateLocationNotification object: locationManager];
    }
    locationManager = nil;
}

#pragma mark - Services Alert Request

/**
    @abstract Показывает пользователю геолокационный алерт
    @discussion
    Оповещает пользователя о том, что геолокация не включена (только, если в предыдущие разы пользователь отказался). И предлагает все-таки включить геолокацию (перейти в настройки)
    @note Теперь пользователь переходит всегда в текущие настройки геолокации (осуществляется роутинг по preferences)
 */
- (void)geolocationAlertIfNeeded{
    
    if(self.authorizationStatus == kCLAuthorizationStatusDenied || self.authorizationStatus == kCLAuthorizationStatusRestricted){
        
        NSURL *locationSettingsURL = [self locationSettingsURL];
        if([application canOpenURL:locationSettingsURL]){
            
            DSJOURNALLING_LOG(@"Location User Dialog Retry custom request permissions");
            
            //UIAlertView *authAlert = [[UIAlertView alloc] initWithTitle:TZLocalizedString(@"GeolocationSwitchToOn", @"") message:@"" delegate:self cancelButtonTitle:TZLocalizedString(@"Cancel2", @"") otherButtonTitles:TZLocalizedString(@"OpenSettings", @""), nil];
            //[authAlert show];
        }
    }
}

/// URL System Preferences (позволяет перейти в геолокационные сервисы в настройках)
- (NSURL*)locationSettingsURL{
    
    static NSURL *locationSettingsURL = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        locationSettingsURL = [NSURL URLWithString:@"prefs:root=LOCATION_SERVICES"];
    });
    return locationSettingsURL;
}


@end
