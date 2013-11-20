//
//  RouteController.h
//  SmartShop
//
//  Created by Batman on 20/11/2013.
//  Copyright (c) 2013 Batman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface RouteController : NSObject

@property (strong, nonatomic) NSMutableArray *routesArr;

-(id) initWithShops:(NSMutableArray *) shopsArr  andLocation:(CLLocationCoordinate2D) origin;

@end
