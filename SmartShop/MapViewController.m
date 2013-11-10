//
//  MapViewController.m
//  SmartShop
//
//  Created by Batman on 06/11/2013.
//  Copyright (c) 2013 Batman. All rights reserved.
//

#import "MapViewController.h"
#import "Location.h"

@interface MapViewController ()

@property (strong, nonatomic) MKPolyline *routeLine;
@property (strong, nonatomic) MKPolylineView *routeLineView;

@end

@implementation MapViewController

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)placeAnnotationOnMap:(MKPointAnnotation *)annotationView
{
    [self.mapView addAnnotation:(id)annotationView];
    
    MKMapCamera *camera = [MKMapCamera  cameraLookingAtCenterCoordinate:annotationView.coordinate fromEyeCoordinate:annotationView.coordinate eyeAltitude:70000.0];
    
    [UIView animateWithDuration:1.0 animations:^{
        [self.mapView setCamera:camera];
    }];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSMutableArray *clAllAndReverseLocationArray = [[NSMutableArray alloc] init];
    for (NSMutableArray *newRoute in self.locationArray) {
        
        NSMutableArray *clLocationArray = [[NSMutableArray alloc] init];
        for (Location *location in newRoute) {
            CLLocation *clLocation = [[CLLocation alloc]
                                      initWithLatitude:location.lat
                                      longitude:location.lng];
            [clLocationArray addObject:clLocation];
        }
        [clAllAndReverseLocationArray addObjectsFromArray:clLocationArray];
        // reverse array
        NSMutableArray *array = [NSMutableArray arrayWithCapacity:[clLocationArray count]];
        NSEnumerator *enumerator = [clLocationArray reverseObjectEnumerator];
        for (id element in enumerator) {
            [array addObject:element];
        }
        [clAllAndReverseLocationArray addObjectsFromArray:array];
    }
    [self drawLineWithLocationArray:clAllAndReverseLocationArray];
    
    /*
    NSMutableArray *clLocationArray = [[NSMutableArray alloc] init];
    for (Location *location in self.locationArray) {
        CLLocation *clLocation = [[CLLocation alloc]
                                  initWithLatitude:location.lat
                                  longitude:location.lng];
        [clLocationArray addObject:clLocation];
    }
     */
    // [self drawLineWithLocationArray:clLocationArray];
    [self placeAnnotationOnMap:self.pointAnnotation];
}

#pragma mark -

- (void)drawTestLine
{
    // test code : draw line between Beijing and Hangzhou
    CLLocation *location0 = [[CLLocation alloc] initWithLatitude:39.954245 longitude:116.312455];
    CLLocation *location1 = [[CLLocation alloc] initWithLatitude:30.247871 longitude:120.127683];
    CLLocation *location2 = [[CLLocation alloc] initWithLatitude:32.247871 longitude:121.127683];
    NSArray *array = [NSArray arrayWithObjects:location0, location1, location2, nil];
    [self drawLineWithLocationArray:array];
}

- (void)drawLineWithLocationArray:(NSArray *)locationArray
{
    int pointCount = [locationArray count];
    CLLocationCoordinate2D *coordinateArray = (CLLocationCoordinate2D *)malloc(pointCount * sizeof(CLLocationCoordinate2D));
    
    for (int i = 0; i < pointCount; ++i) {
        CLLocation *location = [locationArray objectAtIndex:i];
        coordinateArray[i] = [location coordinate];
    }
    
    [self.mapView removeOverlay:self.routeLine];
    
    self.routeLine = [MKPolyline polylineWithCoordinates:coordinateArray count:pointCount];
    [self.mapView setVisibleMapRect:[self.routeLine boundingMapRect]];
    [self.mapView addOverlay:self.routeLine];
    
    free(coordinateArray);
    coordinateArray = NULL;
}

#pragma mark - MKMapViewDelegate

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay
{
    if(overlay == self.routeLine) {
        if(nil == self.routeLineView) {
            self.routeLineView = [[MKPolylineView alloc] initWithPolyline:self.routeLine];
            self.routeLineView.fillColor = [UIColor redColor];
            self.routeLineView.strokeColor = [UIColor redColor];
            self.routeLineView.lineWidth = 2;
        }
        return self.routeLineView;
    }
    return nil;
}

@end
