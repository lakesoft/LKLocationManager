//
//  LKReverseGeocoder.m
//  LKLocationManager
//
//  Created by Hiroshi Hashiguchi on 2014/01/27.
//  Copyright (c) 2014年 lakesoft. All rights reserved.
//

#import "LKReverseGeocoder.h"
@import Contacts;

NSString* const LKReverseGeocoderKeyPlacemarks = @"LKReverseGeocoderKeyPlacemarks";
NSString* const LKReverseGeocoderKeyAddressString = @"LKReverseGeocoderKeyAddressString";
NSString* const LKReverseGeocoderKeyAddressDictionary = @"LKReverseGeocoderKeyAddressDictionary";
NSString* const LKReverseGeocoderKeyError = @"LKReverseGeocoderKeyError";

@implementation LKReverseGeocoder

#pragma mark - API (Reverse geocoding)
+ (void)reverseGeocodeLocation:(CLLocation *)location completionHandler:(LKGeocodeCompletionHandler)completionHandler
{
    CLGeocoder* geocoder = CLGeocoder.new;
    [geocoder reverseGeocodeLocation:location
                   completionHandler:^(NSArray* placemarks, NSError* error) {
                       NSString* addressString = nil;
                       NSDictionary* addressDictionary = nil;
                       if (error) {
                           NSLog(@"%s: %@", __PRETTY_FUNCTION__, error);
                       } else {
                           CLPlacemark* placemark = [placemarks objectAtIndex:0];
                           addressDictionary = placemark.addressDictionary;
                           NSString* state = addressDictionary[@"State"];
                           NSString* city = addressDictionary[@"City"];
                           NSString* street = addressDictionary[@"Street"];
                           NSMutableDictionary* address = @{}.mutableCopy;
                           if (state) {
                               address[CNPostalAddressStateKey] = state;
                           }
                           if (city) {
                               address[CNPostalAddressCityKey] = city;
                           }
                           if (street) {
                               address[CNPostalAddressStreetKey] = street;
                           }
                           addressString = ABCreateStringWithAddressDictionary(address, NO);
                           addressString = [addressString stringByReplacingOccurrencesOfString:@"\n"
                                                                                    withString:@""];
                       }
                       completionHandler(placemarks, addressString, addressDictionary, error);
                   }];
    
}


+ (NSDictionary*)placeInformationWithLocation:(CLLocation *)location
{
    NSMutableDictionary* dict = @{}.mutableCopy;
    __block BOOL finished = NO;
    [self reverseGeocodeLocation:location
               completionHandler:^(NSArray *placemarks, NSString *addressString, NSDictionary *addressDictionary, NSError *error) {
                   if (placemarks) {
                       dict[LKReverseGeocoderKeyPlacemarks] = placemarks;
                   }
                   if (addressString) {
                       dict[LKReverseGeocoderKeyAddressString] = addressString;
                   }
                   if (addressDictionary) {
                       dict[LKReverseGeocoderKeyAddressDictionary] = addressDictionary;
                   }
                   if (error) {
                       dict[LKReverseGeocoderKeyError] = error;
                   }
                   finished = YES;
               }];
    while (!finished) {
        [NSRunLoop.currentRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    }

    return dict;
}
@end
