//
//  Location.m
//  SmartShop
//
//  Created by Batman on 10/11/2013.
//  Copyright (c) 2013 Batman. All rights reserved.
//

#import "Location.h"

@implementation Location

@synthesize lat;
@synthesize lng;

-(NSString *)description
{
    return [[NSString alloc] initWithFormat:@"%f %f", lat, lng];
}

@end
