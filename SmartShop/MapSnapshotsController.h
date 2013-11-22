//
//  MapSnapShotsController.h
//  SmartShop
//
//  Created by Batman on 20/11/2013.
//  Copyright (c) 2013 Batman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

#import "UpdateViewDelegate.h"

@interface MapSnapshotsController : NSObject

@property (strong, nonatomic) MKMapView *mapView; // the mapview needs to be set for it to create snap shopts
@property (strong, nonatomic) NSMutableArray *imagesArr; //  the generated images are stored here
@property (weak, nonatomic) id<UpdateViewDelegate> delegate; // The delegate used to udpate views

// Create snap shot of shops which have a location stored in them
-(id) initWithShops:(NSMutableArray *)shopsArr withMapView:(MKMapView *) mapView;

@end
