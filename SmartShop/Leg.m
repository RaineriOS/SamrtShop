//
//  Leg.m
//  SmartShop
//
//  Created by Batman on 10/11/2013.
//  Copyright (c) 2013 Batman. All rights reserved.
//

#import "Leg.h"

@implementation Leg

@synthesize startAddress;
@synthesize endAddress;
@synthesize startLocation;
@synthesize endLocation;
@synthesize stepsArray;


-(NSString *)description
{
    return [[NSString alloc] initWithFormat:@"%@ --- %@ --- (%@ - %@) %@",
            startAddress, endAddress, startLocation, endLocation, stepsArray,nil];
}

@end
