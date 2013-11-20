//
//  MapSnapShotsController.h
//  SmartShop
//
//  Created by Batman on 20/11/2013.
//  Copyright (c) 2013 Batman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface MapSnapShotsController : NSObject

@property (strong, nonatomic) MKMapView *mapView;
@property (strong, nonatomic) NSMutableArray *imagesArr;

-(id) initWithShops:(NSMutableArray *)shopsArr withMapView:(MKMapView *) mapView;

@end
