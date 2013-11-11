//
//  Leg.h
//  SmartShop
//
//  Created by Batman on 10/11/2013.
//  Copyright (c) 2013 Batman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Location.h"

@interface Leg : NSObject

@property (strong, nonatomic) NSString *startAddress;
@property (strong, nonatomic) NSString *endAddress;
@property (strong, nonatomic) NSString *distance;
@property (strong, nonatomic) NSString *duration;
@property (strong, nonatomic) NSMutableArray *stepsArray;

@property (strong, nonatomic) Location *startLocation;
@property (strong, nonatomic) Location *endLocation;

@end
