//
//  Step.h
//  SmartShop
//
//  Created by Batman on 10/11/2013.
//  Copyright (c) 2013 Batman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Location.h"

@interface Step : NSObject

@property (strong, nonatomic) NSString *travelMode;
@property (strong, nonatomic) Location *startLocation;
@property (strong, nonatomic) Location *endLocation;

@end
