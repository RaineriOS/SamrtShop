//
//  MapViewController.h
//  SmartShop
//
//  Created by Batman on 06/11/2013.
//  Copyright (c) 2013 Batman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface MapViewController : UIViewController <MKMapViewDelegate>

@property (strong, nonatomic) MKPointAnnotation *pointAnnotation;
@property (strong, nonatomic) NSArray *locationArray;
@property (strong, nonatomic) IBOutlet MKMapView *mapView;

-(void) placeAnnotationOnMap:(MKPointAnnotation *)annotationView;
+ (MKPolyline *)polylineWithEncodedString:(NSString *)encodedString;

@end
