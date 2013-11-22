//
//  MapViewController.h
//  SmartShop
//
//  Created by Batman on 06/11/2013.
//  Copyright (c) 2013 Batman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "UpdateViewDelegate.h"

@protocol StepByStepRouteViewDelegate <NSObject>

-(void)drawAndDirectRoute:(NSArray *) routeArr withDestinationAnnotation:(MKPointAnnotation *)annotationView;

@end

// This is the detail of maps
@interface StepByStepRouteViewController : UIViewController <UpdateViewDelegate, MKMapViewDelegate, UITableViewDataSource, UITableViewDelegate, StepByStepRouteViewDelegate>

// Can be made private
@property (strong, nonatomic) MKPointAnnotation *pointAnnotation;
@property (strong, nonatomic) NSArray *locationArray;
@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

// Place annotation on the map and zoom onto them
-(void) placeAnnotationOnMap:(MKPointAnnotation *)annotationView;
-(void) removeOverlays;
// Decode the google API encoded string
+ (MKPolyline *)polylineWithEncodedString:(NSString *)encodedString;

@end
