//
//  LKLocationManager.m
//  LKLocationManager
//
//  Created by Hiroshi Hashiguchi on 2014/01/27.
//  Copyright (c) 2014年 lakesoft. All rights reserved.
//

#import "LKLocationManager.h"

NSString* const LKLocationManagerDidUpdateLocationNotification = @"LKLocationManagerDidUpdateLocationNotification";
NSString* const LKLocationManagerDidFinishLocationNotification = @"LKLocationManagerDidFinishLocationNotification";

@interface LKLocationManager()  <CLLocationManagerDelegate>
@property (nonatomic, assign) LKLocationManagerStatus status;
@property (nonatomic, retain) CLLocation* location;
@property (nonatomic, retain) CLHeading* heading;
@property (nonatomic, retain) CLLocationManager* locationManager;
@end

#define LK_LOCATION_MANAGER_GETTING_TIME_INTERVAL    15.0
#define LK_LOCATION_MANAGER_HORIZONTAL_ACCURACY      100.0
#define LK_LOCATION_MANAGER_CACHE_TIMEOUT            5.0

@implementation LKLocationManager

#pragma mark - Basics
- (id)init {
    self = [super init];
    if (self) {
        self.locationManager = CLLocationManager.new;
        self.locationManager.delegate = self;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        
        self.status = LKLocationManagerStatusIdle;
        self.gettingTimeInterval = LK_LOCATION_MANAGER_GETTING_TIME_INTERVAL;
        self.stoppingAccuracy = LK_LOCATION_MANAGER_HORIZONTAL_ACCURACY;
        self.cacheTimeout = LK_LOCATION_MANAGER_CACHE_TIMEOUT;
        
        self.location = self.locationManager.location;
    }
    return self;
}


+ (LKLocationManager*)sharedManager
{
    static LKLocationManager* _sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = LKLocationManager.new;
    });
    return _sharedManager;
}


#pragma mark - Privates
- (void)_logLocation:(CLLocation*)location
{
	CLLocationCoordinate2D coordinate = location.coordinate;
	NSLog(@"latitude,logitude : %f, %f", coordinate.latitude, coordinate.longitude);
	NSLog(@"altitude          : %f", location.altitude);
	NSLog(@"cource            : %f", location.course);
	NSLog(@"horizontalAccuracy: %f", location.horizontalAccuracy);
	NSLog(@"verticalAccuracy  : %f", location.verticalAccuracy);
	NSLog(@"speed             : %f", location.speed);
	NSLog(@"timestamp         : %@", location.timestamp);
    NSLog(@"\n");
}


- (void)_stopUpdatingLocationWithStatus:(LKLocationManagerStatus)status
{
    if (self.status != LKLocationManagerStatusLocationUpdating) {
        return;
    }
    
    [self.locationManager stopUpdatingLocation];
    self.status = status;
    
    if (!self.disabled) {
        if (status == LKLocationManagerStatusLocationUpdated) {
            [[NSNotificationCenter defaultCenter]
             postNotificationName:LKLocationManagerDidUpdateLocationNotification
             object:self];
        }
        
        [[NSNotificationCenter defaultCenter]
         postNotificationName:LKLocationManagerDidFinishLocationNotification
         object:self];
    }
}

- (void)_didFinishUpdatingLocation
{
    [self _stopUpdatingLocationWithStatus:LKLocationManagerStatusLocationUpdated];
}


#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager
	didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    if (newLocation.horizontalAccuracy < 0) {
        return;
    }
    
    if (-[newLocation.timestamp timeIntervalSinceNow] > self.cacheTimeout) {
        return; // older timestamp
    }
    
    self.location = newLocation;
    self.heading = manager.heading;
    
    if (!self.disabled) {
        [[NSNotificationCenter defaultCenter]
         postNotificationName:LKLocationManagerDidUpdateLocationNotification
         object:self];
    }
    
    if (self.location.horizontalAccuracy <= self.stoppingAccuracy) {
        [self _stopUpdatingLocationWithStatus:LKLocationManagerStatusLocationUpdated];
        return; // enough accuracy
    }
}


- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    self.location = nil;
    self.heading = nil;
    
    [self _stopUpdatingLocationWithStatus:LKLocationManagerStatusLocationFailed];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (status == kCLAuthorizationStatusNotDetermined) {
        NSString* desc = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"NSLocationAlwaysUsageDescription"];
        if (desc) {
            if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
                [manager requestAlwaysAuthorization];
            }
        } else {
            desc = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"NSLocationWhenInUseUsageDescription"];
            if (desc) {
                [manager requestWhenInUseAuthorization];
            }
        }
    }
}



#pragma mark - API (properties)
- (BOOL)isLocationUpdating
{
    return (self.status == LKLocationManagerStatusLocationUpdating);
}



#pragma mark - API (Control)
- (void)startUpdate
{
    if (self.disabled) {
        return;
    }
    
    if (self.status == LKLocationManagerStatusLocationUpdating) {
        return;
    }
    
    self.status = LKLocationManagerStatusLocationUpdating;
    
    [self performSelector:@selector(_didFinishUpdatingLocation)
               withObject:nil
               afterDelay:self.gettingTimeInterval];
    [self.locationManager startUpdatingLocation];
}

- (void)stopUpdate
{
    switch (self.status) {
        case LKLocationManagerStatusLocationUpdating:
            [self _stopUpdatingLocationWithStatus:LKLocationManagerStatusLocationCanceled];
            break;
            
        default:
            break;
    }
}


- (NSString*)description
{
    return [NSString stringWithFormat:@"%f,%f",
            self.location.coordinate.latitude, self.location.coordinate.longitude];
}



@end
