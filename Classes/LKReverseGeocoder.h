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

// API (asynchronous)
typedef void (^LKGeocodeCompletionHandler)(NSArray *placemarks,     // <CLPlacemark>
                                           NSString* addressString,
                                           NSDictionary* addressDictionary,
                                           NSError *error);

// addressDictionary examples
//{
//    City = "San Francisco";
//    Country = "United States";
//    CountryCode = US;
//    FormattedAddressLines =     (
//                                 "Apple Store, San Francisco",
//                                 "1800 Ellis St",
//                                 "San Francisco, CA  94115-4004",
//                                 "United States"
//                                 );
//    Name = "Apple Store, San Francisco";
//    PostCodeExtension = 4004;
//    State = CA;
//    Street = "1800 Ellis St";
//    SubAdministrativeArea = "San Francisco";
//    SubLocality = "Union Square";
//    SubThoroughfare = 1800;
//    Thoroughfare = "Ellis St";
//    ZIP = 94115;
//}

+ (void)reverseGeocodeLocation:(CLLocation *)location completionHandler:(LKGeocodeCompletionHandler)completionHandler;

// API (synchronous)
+ (NSDictionary*)reverseGeocodeLocation:(CLLocation *)location;

// keys
extern NSString* const LKReverseGeocoderKeyPlacemarks;
extern NSString* const LKReverseGeocoderKeyAddressString;
extern NSString* const LKReverseGeocoderKeyAddressDictionary;
extern NSString* const LKReverseGeocoderKeyError;


@end
