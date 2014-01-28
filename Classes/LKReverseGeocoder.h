//
//  LKReverseGeocoder.h
//  LKLocationManager
//
//  Created by Hiroshi Hashiguchi on 2014/01/27.
//  Copyright (c) 2014年 lakesoft. All rights reserved.
//

@import CoreLocation;
@import AddressBookUI;

@interface LKReverseGeocoder : NSObject

// API (Reverse geocoding)
typedef void (^LKGeocodeCompletionHandler)(NSArray *placemarks, NSString* addressString,
                                           NSDictionary* addressDictionary, NSError *error);

+ (void)reverseGeocodeLocation:(CLLocation *)location completionHandler:(LKGeocodeCompletionHandler)completionHandler;

@end
