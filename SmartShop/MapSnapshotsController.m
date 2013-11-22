//
//  MapSnapShotsController.m
//  SmartShop
//
//  Created by Batman on 20/11/2013.
//  Copyright (c) 2013 Batman. All rights reserved.
//

#import "MapSnapshotsController.h"
#import "GoogleAPIShop.h"

@implementation MapSnapshotsController

@synthesize imagesArr;

-(id)init
{
    self = [super init];
    if (self) {
        imagesArr = [[NSMutableArray alloc] init];
    }
    return self;
}

-(id) initWithShops:(NSMutableArray *)shopsArr withMapView:(MKMapView *)mapView
{
    self = [self init];
    if (self) {
        self.mapView = mapView;
        int i = 0;
        [imagesArr removeAllObjects];
        // Create the empty array of images
        for (int i=0; i<shopsArr.count; i++)
            [imagesArr addObject:[[NSObject alloc] init]];
        for (GoogleAPIShop *shop in shopsArr) {
            double lat = shop.location.lat;
            double lng = shop.location.lng;
            CLLocationCoordinate2D dest = CLLocationCoordinate2DMake(lat, lng);
            [self createImage:dest forIndex:i];
            i++;
        }
    }
    return self;
}

// Based on a given destination, create an image in the mapview and take a snapshot of it
-(void)createImage:(CLLocationCoordinate2D) dest forIndex:(int) i;
{
    
       //[self getDirectionsFrom:self.origin to:dest forCell:cell];
       // Camera snap shot thing
    MKMapCamera *camera = [MKMapCamera
                           cameraLookingAtCenterCoordinate:dest
                           fromEyeCoordinate:dest
                           eyeAltitude:500.0];
    
    [self.mapView setCamera:camera];
    
    MKMapSnapshotOptions *options = [[MKMapSnapshotOptions alloc] init];
    options.region = self.mapView.region;
    options.scale = [UIScreen mainScreen].scale;
    options.size = self.mapView.frame.size;
    
    MKMapSnapshotter *snapshotter = [[MKMapSnapshotter alloc] initWithOptions:options];
    [snapshotter startWithQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) completionHandler:^(MKMapSnapshot *snapshot, NSError *error) {
        
        // get the image associated with the snapshot
        UIImage *image = snapshot.image;
        
        // Get a standard annotation view pin. Clearly, Apple assumes that we'll only want to draw standard annotation pins!
        MKAnnotationView *pin = [[MKPinAnnotationView alloc] initWithAnnotation:nil reuseIdentifier:@""];
        UIImage *pinImage = pin.image;
        
        // ok, let's start to create our final image
        UIGraphicsBeginImageContextWithOptions(image.size, YES, image.scale);
        
        // first, draw the image from the snapshotter
        [image drawAtPoint:CGPointMake(0, 0)];
        
        // CGPoint point = [snapshot pointForCoordinate:annotation.coordinate];
        CGPoint point = [snapshot pointForCoordinate:dest];
        CGPoint pinCenterOffset = pin.centerOffset;
        point.x -= pin.bounds.size.width / 2.0;
        point.y -= pin.bounds.size.height / 2.0;
        point.x += pinCenterOffset.x;
        point.y += pinCenterOffset.y;
        
        [pinImage drawAtPoint:point];
        
        // grab the final image
        UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [imagesArr addObject:finalImage];
        if (imagesArr.count > i) {
            [imagesArr replaceObjectAtIndex:i withObject:finalImage];
            if ([self.delegate respondsToSelector:@selector(updateView)]) {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [self.delegate updateView];
                });
            }
        }
    }];
}

@end
