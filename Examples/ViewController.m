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
                            }];
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
