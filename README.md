LKLocationManager
=================

Location Library to get location easily. And Supports reverse Geo cording.

## Usage

### Getting Location

step1: add observer for notifications

    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(_updatedLocation:)
                                               name:LKLocationManagerDidUpdateLocationNotification
                                             object:nil];
                                             
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(_finishedLocation:)
                                               name:LKLocationManagerDidFinishLocationNotification
                                             object:nil];

step2: implement notification handlers

    - (void)_updatedLocation:(NSNotification*)notification
    {
      LKLocationManager* manager = notification.object;
      CLLocation* location = manager.location;
        :
    }
        
    - (void)_finishedLocation:(NSNotification*)notification
    {
      LKLocationManager* manager = notification.object;
      CLLocation* location = manager.location;
        :
    }


step3: start updating location

    [LKLocationManager.sharedManager startUpdate];

Fetching location is stopped automatically when the accuracy is enough. stoppingAccuracy property is used to determine to stop (default 100.0).

You can stop manually

    [LKLocationManager.sharedManager stopUpdate];

Status:

    typedef NS_ENUM(NSInteger, LKLocationManagerStatus) {
        LKLocationManagerStatusIdle = 0,
        LKLocationManagerStatusLocationUpdating,
        LKLocationManagerStatusLocationUpdated,
        LKLocationManagerStatusLocationCanceled,
        LKLocationManagerStatusLocationFailed
    };


### Reverse geocording

    [LKReverseGeocoder reverseGeocodeLocation:manager.location
                            completionHandler:^(NSArray *placemarks,
                                              NSString *addressString,
                                              NSDictionary *addressDictionary,
                                              NSError *error) {
                                self.place.text = addressString;
                                  :
                            }];

'addressString' is localized.


- - - -
Please see Example project.



## Installation

LKUserDefaults is available through [CocoaPods](http://cocoapods.org), to install
it simply add the following line to your Podfile:

    pod "LKLocationManager", :git => 'https://github.com/lakesoft/LKLocationManager.git'


## Author

Hiroshi Hashiguchi, xcatsan@mac.com

## License

LKArchiver is available under the MIT license. See the LICENSE file for more info.

