//
//  ShopController.h
//  SmartShop
//
//  Created by Batman on 19/11/2013.
//  Copyright (c) 2013 Batman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface ShopController : NSObject

@property (strong, nonatomic) NSMutableArray *shopsArr;
-(void)searchForShops:(CLLocationCoordinate2D)origin completionBlock:(void(^)())block;

@end
