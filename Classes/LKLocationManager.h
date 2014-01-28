//
//  LKLocationManager.h
//  LKLocationManager
//
//  Created by Hiroshi Hashiguchi on 2014/01/27.
//  Copyright (c) 2014年 lakesoft. All rights reserved.
//

@import CoreLocation;

typedef NS_ENUM(NSInteger, LKLocationManagerStatus) {
    LKLocationManagerStatusIdle = 0,
    LKLocationManagerStatusLocationUpdating,
    LKLocationManagerStatusLocationUpdated,
    LKLocationManagerStatusLocationCanceled,
    LKLocationManagerStatusLocationFailed
};

#pragma mark - Notifications
// notification.objcet=LKLocationManager instance
extern NSString* const LKLocationManagerDidUpdateLocationNotification;
extern NSString* const LKLocationManagerDidFinishLocationNotification;

@interface LKLocationManager : NSObject

#pragma mark - API (factory)
+ (LKLocationManager*)sharedManager;

#pragma mark - Properties (readonly)
@property (nonatomic, assign, readonly) LKLocationManagerStatus status;
@property (nonatomic, retain, readonly) CLLocation* location;
@property (nonatomic, retain, readonly) CLHeading* heading;
@property (nonatomic, assign, readonly) BOOL isLocationUpdating;

#pragma mark - Properties (setting)
@property (nonatomic, assign) NSTimeInterval gettingTimeInterval;
@property (nonatomic, assign) CGFloat cacheTimeout; // [SEC]
@property (nonatomic, assign) CLLocationAccuracy stoppingAccuracy;
@property (nonatomic, assign) BOOL disabled;

#pragma mark - API (control)
- (void)startUpdate;
- (void)stopUpdate;

@end
