//
//  GetLocationShopViewController.h
//  SmartShop
//
//  Created by Batman on 14/11/2013.
//  Copyright (c) 2013 Batman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface GetLocationShopViewController : UIViewController <CLLocationManagerDelegate>

@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) MKPointAnnotation *annotationView;

-(void)placeAnnotationOnMap:(MKPointAnnotation *)annotationView;

@end
