//
//  ViewController.m
//  LKLocationManager
//
//  Created by Hiroshi Hashiguchi on 2014/01/27.
//  Copyright (c) 2014年 lakesoft. All rights reserved.
//

#import "ViewController.h"
#import "LKLocationManager.h"
#import "LKReverseGeocoder.h"
#import "LKAddressTemplate.h"
#import "LKAddressTemplateDescription.h"
#import <MapKit/MapKit.h>

@interface MapAnnotation : NSObject <MKAnnotation>
+ (MapAnnotation*)mapAnnotationWithCoordinate:(CLLocationCoordinate2D)coordinate;
@end

@interface MapAnnotation()
@property (assign, nonatomic) CLLocationCoordinate2D coordinate;
@end

@implementation MapAnnotation
+ (MapAnnotation*)mapAnnotationWithCoordinate:(CLLocationCoordinate2D)coordinate
{
    MapAnnotation* mapAnnotation = self.new;
    mapAnnotation.coordinate = coordinate;
    return mapAnnotation;
}
@end

@interface ViewController () <MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UILabel *coordinate;
@property (weak, nonatomic) IBOutlet UILabel *place;
@property (weak, nonatomic) IBOutlet UILabel *status;
@property (assign, nonatomic) NSTimeInterval startTimeInterval;

@property (strong, nonatomic) MKCircle* circle;

@end

@implementation ViewController

- (void)_updateStatusLabel
{
    NSString* text = nil;
    switch (LKLocationManager.sharedManager.status) {
        case LKLocationManagerStatusIdle:
            text = @"Idle";
            break;
            
        case LKLocationManagerStatusLocationUpdating:
            text = @"Updating";
            break;
            
        case LKLocationManagerStatusLocationFailed:
            text = @"Failed";
            break;
            
        case LKLocationManagerStatusLocationCanceled:
            text = @"Canceled";
            break;
            
        case LKLocationManagerStatusLocationUpdated:
            text = @"Updated";
            break;
            
        default:
            text = @"(unknown)";
            break;
    }
    NSTimeInterval elapse = [NSDate.date timeIntervalSinceReferenceDate] - self.startTimeInterval;
    self.status.text = [NSString stringWithFormat:@"%@ [%0.5fs]", text, elapse];
}

- (void)_updated:(NSNotification*)n
{
    CLLocation* location = LKLocationManager.sharedManager.location;
    self.coordinate.text = [NSString stringWithFormat:@"%0.5f / %0.5f", location.coordinate.latitude, location.coordinate.longitude];
    
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self.mapView removeOverlays:self.mapView.overlays];
    
    [self.mapView setCenterCoordinate:location.coordinate animated:YES];
    
    MapAnnotation* annotation = [MapAnnotation mapAnnotationWithCoordinate:location.coordinate];
    [self.mapView addAnnotation:annotation];
    
    
    MKCircle *circle = [MKCircle circleWithCenterCoordinate:location.coordinate
                                                     radius:location.horizontalAccuracy];
    [self.mapView addOverlay:circle];
    
}

- (void)_finished:(NSNotification*)n
{
    [self _updateStatusLabel];
    LKLocationManager* manager = n.object;
    [LKReverseGeocoder reverseGeocodeLocation:manager.location
                            completionHandler:^(NSArray *placemarks, NSString *addressString, NSDictionary *addressDictionary, NSError *error) {
                                self.place.text = addressString;
                                NSLog(@"%@", addressString);
                                NSLog(@"%@", addressDictionary);
                                NSLog(@"%@", placemarks);
                                
                                NSString* template = @"\n"\
                                @"addr.Citry                 : %addr.City\n"\
                                @"addr.Country               : %addr.Country\n"\
                                @"addr.CountryCode           : %addr.CountryCode\n"\
                                @"addr.Name                  : %addr.Name\n"\
                                @"addr.PostCodeExtension     : %addr.PostCodeExtension\n"\
                                @"addr.State                 : %addr.State\n"\
                                @"addr.Street                : %addr.Street\n"\
                                @"addr.SubAdministrativeArea : %addr.SubAdministrativeArea\n"\
                                @"addr.SubLocality           : %addr.SubLocality\n"\
                                @"addr.SubThoroughfare       : %addr.SubThoroughfare\n"\
                                @"addr.Thoroughfare          : %addr.Thoroughfare\n"\
                                @"addr.ZIP                   : %addr.ZIP\n"\
                                ;
                                NSString* result = [LKAddressTemplate convertWithTemplate:template
                                                                        addressDictionary:addressDictionary];
                                NSLog(@"%@", result);
                                
                                NSMutableString* str = NSMutableString.string;
                                [str appendString:@"\n"];
                                for (int i=0; i < LKAddressTemplate.numberOfKeywords; i++) {
                                    LKAddressTemplateDescription* desc = [LKAddressTemplate descriptionAtIndex:i];
                                    [str appendFormat:@"%@: %@\n", desc.keyword, desc.title];
                                }
                                NSLog(@"%@", str);
                            }];
}


- (void)_rev:(NSString*)key lat:(CLLocationDegrees)lat lon:(CLLocationDegrees)lon
{
    CLLocation* loc;
    
    loc = [[CLLocation alloc] initWithCoordinate:CLLocationCoordinate2DMake(lat, lon)
                                        altitude:0.0
                              horizontalAccuracy:kCLLocationAccuracyThreeKilometers
                                verticalAccuracy:kCLLocationAccuracyThreeKilometers
                                       timestamp:NSDate.date];
    NSDictionary* dict = [LKReverseGeocoder reverseGeocodeLocation:loc];
    NSLog(@"%@", dict[LKReverseGeocoderKeyAddressString]);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self _updateStatusLabel];
    
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(_updated:)
                                               name:LKLocationManagerDidUpdateLocationNotification
                                             object:nil];

    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(_finished:)
                                               name:LKLocationManagerDidFinishLocationNotification
                                             object:nil];
    
    [self _updateStatusLabel];

    CLLocationCoordinate2D coordinate = CLLocationManager.new.location.coordinate;
    MKCoordinateSpan span = MKCoordinateSpanMake(0.0025, 0.0025);
    MKCoordinateRegion coordinateRegion = MKCoordinateRegionMake(coordinate, span);
    [self.mapView setRegion:coordinateRegion animated:YES];
    [self.mapView addAnnotation:[MapAnnotation mapAnnotationWithCoordinate:coordinate]];

    [self update:nil];
    
    
    
    // thaks for http://www.benricho.org/chimei/latlng_data.html
    [self _rev:@"札幌市" lat:43.063968 lon:141.347899];
    [self _rev:@"青森市" lat:40.824623 lon:140.740593];
    [self _rev:@"盛岡市" lat:39.703531 lon:141.152667];
    [self _rev:@"仙台市" lat:38.268839 lon:140.872103];
    [self _rev:@"秋田市" lat:39.718600 lon:140.102334];
    [self _rev:@"山形市" lat:38.240437 lon:140.363634];
    [self _rev:@"福島市" lat:37.750299 lon:140.467521];
    [self _rev:@"水戸市" lat:36.341813 lon:140.446793];
    [self _rev:@"宇都宮市" lat:36.565725 lon:139.883565];
    [self _rev:@"前橋市" lat:36.391208 lon:139.060156];
    [self _rev:@"さいたま市" lat:35.857428 lon:139.648933];
    [self _rev:@"千葉市" lat:35.605058 lon:140.123308];
    [self _rev:@"新宿区" lat:35.689521 lon:139.691704];
    [self _rev:@"横浜市" lat:35.447753 lon:139.642514];
    [self _rev:@"新潟市" lat:37.902418 lon:139.023221];
    [self _rev:@"富山市" lat:36.695290 lon:137.211338];
    [self _rev:@"金沢市" lat:36.594682 lon:136.625573];
    [self _rev:@"福井市" lat:36.065219 lon:136.221642];
    [self _rev:@"甲府市" lat:35.664158 lon:138.568449];
    [self _rev:@"長野市" lat:36.651289 lon:138.181224];
    [self _rev:@"岐阜市" lat:35.391227 lon:136.722291];
    [self _rev:@"静岡市" lat:34.976978 lon:138.383054];
    [self _rev:@"名古屋市" lat:35.180188 lon:136.906565];
    [self _rev:@"津市" lat:34.730283 lon:136.508591];
    [self _rev:@"大津市" lat:35.004531 lon:135.86859];
    [self _rev:@"京都市" lat:35.021004 lon:135.755608];
    [self _rev:@"大阪市" lat:34.686316 lon:135.519711];
    [self _rev:@"神戸市" lat:34.691279 lon:135.183025];
    [self _rev:@"奈良市" lat:34.685333 lon:135.832744];
    [self _rev:@"和歌山市" lat:34.226034 lon:135.167506];
    [self _rev:@"鳥取市" lat:35.503869 lon:134.237672];
    [self _rev:@"松江市" lat:35.472297 lon:133.050499];
    [self _rev:@"岡山市" lat:34.661772 lon:133.934675];
    [self _rev:@"広島市" lat:34.396560 lon:132.459622];
    [self _rev:@"山口市" lat:34.186121 lon:131.470500];
    [self _rev:@"徳島市" lat:34.065770 lon:134.559303];
    [self _rev:@"高松市" lat:34.340149 lon:134.043444];
    [self _rev:@"松山市" lat:33.84166 lon:132.765362];
    [self _rev:@"高知市" lat:33.559705 lon:133.53108];
    [self _rev:@"福岡市" lat:33.606785 lon:130.418314];
    [self _rev:@"佐賀市" lat:33.249367 lon:130.298822];
    [self _rev:@"長崎市" lat:32.744839 lon:129.873756];
    [self _rev:@"熊本市" lat:32.789828 lon:130.741667];
    [self _rev:@"大分市" lat:33.238194 lon:131.612591];
    [self _rev:@"宮崎市" lat:31.911090 lon:131.423855];
    [self _rev:@"鹿児島市" lat:31.560148 lon:130.557981];
    [self _rev:@"那覇市" lat:26.212401 lon:127.680932];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (IBAction)update:(id)sender {
    self.startTimeInterval = [NSDate.date timeIntervalSinceReferenceDate];
    self.coordinate.text = nil;
    self.place.text = nil;
    [LKLocationManager.sharedManager startUpdate];
    [self _updateStatusLabel];
}


#pragma mark MKMapViewDelegate
-(MKOverlayRenderer *)mapView:(MKMapView*)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    
    MKCircle * circle = (MKCircle *)overlay;
    
    MKCircleRenderer * renderer = [[MKCircleRenderer alloc] initWithCircle:circle];
    renderer.strokeColor = [UIColor colorWithRed:0.5 green:0.5 blue:1.0 alpha:0.4];
    renderer.fillColor = [UIColor colorWithRed:0.5 green:0.5 blue:1.0 alpha:0.2];
    renderer.lineWidth = 0.5;
    return renderer;
    
}

@end
