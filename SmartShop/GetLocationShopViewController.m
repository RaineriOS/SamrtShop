//
//  GetLocationShopViewController.m
//  SmartShop
//
//  Created by Batman on 14/11/2013.
//  Copyright (c) 2013 Batman. All rights reserved.
//

#import "GetLocationShopViewController.h"

@interface GetLocationShopViewController ()

@property (strong, nonatomic) CLLocationManager *locationManager;

@end

@implementation GetLocationShopViewController

@synthesize locationManager;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    // UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addPin:)];
    UILongPressGestureRecognizer *recognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(addPin:)];
    //[recognizer setNumberOfTapsRequired:1];
    [self.mapView addGestureRecognizer:recognizer];
    locationManager = [[CLLocationManager alloc] init];
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation; // 100 m
    locationManager.delegate = self;
    [locationManager startUpdatingLocation];
    
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:@"Error" message:@"Failed to Get Your Location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorAlert show];
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    // If it's a relatively recent event, turn off updates to save power.
    CLLocation* location = [locations lastObject];
    NSDate* eventDate = location.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    if (abs(howRecent) < 15.0) {
        // If the event is recent, do something with it.
        NSLog(@"latitude %+.6f, longitude %+.6f\n",
              location.coordinate.latitude,
              location.coordinate.longitude);
    }
   if (self.annotationView)
       [self.mapView removeAnnotation:self.annotationView];
    self.annotationView = [[MKPointAnnotation alloc] init];
    self.annotationView.coordinate = location.coordinate;
    [self placeAnnotationOnMap:self.annotationView];
}

#pragma mark - update map view UI
// Add pin to the map
- (void)addPin:(UITapGestureRecognizer*)recognizer
{
    [self.locationManager stopUpdatingLocation];
    CGPoint tappedPoint = [recognizer locationInView:self.mapView];
    NSLog(@"Tapped At : %@",NSStringFromCGPoint(tappedPoint));
    CLLocationCoordinate2D coord= [self.mapView convertPoint:tappedPoint toCoordinateFromView:self.mapView];
    NSLog(@"lat  %f",coord.latitude);
    NSLog(@"long %f",coord.longitude);
    MKPointAnnotation *annotationView = [[MKPointAnnotation alloc] init];
    annotationView.coordinate = CLLocationCoordinate2DMake(coord.latitude, coord.longitude);
    if (self.annotationView)
        [self.mapView removeAnnotation:self.annotationView];
    self.annotationView = annotationView;
    [self placeAnnotationOnMap:self.annotationView];
    // add an annotation with coord
}

-(void)placeAnnotationOnMap:(MKPointAnnotation *)annotationView
{
    [self.mapView addAnnotation:(id)annotationView];
    
    MKMapCamera *camera = [MKMapCamera
                           cameraLookingAtCenterCoordinate:annotationView.coordinate
                           fromEyeCoordinate:annotationView.coordinate
                           eyeAltitude:70000.0];
    
    [UIView animateWithDuration:1.0 animations:^{
        [self.mapView setCamera:camera];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
