//
//  Route.m
//  SmartShop
//
//  Created by Batman on 10/11/2013.
//  Copyright (c) 2013 Batman. All rights reserved.
//

#import "Route.h"

@implementation Route

@synthesize copyrights;
@synthesize warnings;
@synthesize legsArray;

-(NSString *)description
{
    return [[NSString alloc] initWithFormat:@"%@ %@ %@", copyrights, warnings, legsArray, nil];
}

@end
