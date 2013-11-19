//
//  ShopController.h
//  SmartShop
//
//  Created by Batman on 19/11/2013.
//  Copyright (c) 2013 Batman. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ShopAndRouteController : NSObject

@property (strong, nonatomic) NSMutableArray *shopsAndDirectionsArr;
-(void)searchForShops:(NSString *)city;

@end
