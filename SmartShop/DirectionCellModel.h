//
//  DirectionCellModel.h
//  SmartShop
//
//  Created by Batman on 19/11/2013.
//  Copyright (c) 2013 Batman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GoogleAPIShop.h"

@interface DirectionCellModel : NSObject

@property (strong, nonatomic) GoogleAPIShop *shop;
@property (strong, nonatomic) NSString *origin;
@property (strong, nonatomic) NSString *destination;
@property (strong, nonatomic) NSString *distance;
@property (strong, nonatomic) NSString *duration;
@property (strong, nonatomic) NSArray *routes;

@end
