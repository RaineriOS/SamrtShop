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

@property (strong, nonatomic) MKMapView *mapView;
@property (strong, nonatomic) NSMutableArray *imagesArr;
@property (weak, nonatomic) id<UpdateViewDelegate> delegate;

-(id) initWithShops:(NSMutableArray *)shopsArr withMapView:(MKMapView *) mapView;

@end
