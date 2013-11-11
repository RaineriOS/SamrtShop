//
//  Step.m
//  SmartShop
//
//  Created by Batman on 10/11/2013.
//  Copyright (c) 2013 Batman. All rights reserved.
//

#import "Step.h"

@implementation Step

@synthesize travelMode;
@synthesize distance;
@synthesize duration;
@synthesize htmlInstructions;
@synthesize maneuver;
@synthesize startLocation;
@synthesize endLocation;

-(NSString *)description
{
    return [[NSString alloc] initWithFormat:@"%@ %@ %@ %@ %@ %@ %@",
            travelMode, startLocation,
            endLocation, distance,
            duration, htmlInstructions,
            maneuver];
}

@end
