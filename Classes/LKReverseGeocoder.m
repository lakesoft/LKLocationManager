//
//  LKReverseGeocoder.m
//  LKLocationManager
//
//  Created by Hiroshi Hashiguchi on 2014/01/27.
//  Copyright (c) 2014年 lakesoft. All rights reserved.
//

#import "LKReverseGeocoder.h"

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
                           NSDictionary* address = @{(NSString*)kABPersonAddressStateKey :[addressDictionary objectForKey:@"State"],
                                                     (NSString*)kABPersonAddressCityKey  :[addressDictionary objectForKey:@"City"],
                                                     (NSString*)kABPersonAddressStreetKey:[addressDictionary objectForKey:@"Street"]};
                           addressString = ABCreateStringWithAddressDictionary(address, NO);
                           addressString = [addressString stringByReplacingOccurrencesOfString:@"\n"
                                                                                    withString:@""];
                       }
                       completionHandler(placemarks, addressString, addressDictionary, error);
                   }];
    
}


@end
