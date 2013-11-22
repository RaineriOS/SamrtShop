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

@interface StepByStepRouteViewController : UIViewController <UpdateViewDelegate, MKMapViewDelegate, UITableViewDataSource, UITableViewDelegate, StepByStepRouteViewDelegate>

// Can be made private
@property (strong, nonatomic) MKPointAnnotation *pointAnnotation;
@property (strong, nonatomic) NSArray *locationArray;
@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

-(void) placeAnnotationOnMap:(MKPointAnnotation *)annotationView;
-(void) removeOverlays;
+ (MKPolyline *)polylineWithEncodedString:(NSString *)encodedString;

@end
