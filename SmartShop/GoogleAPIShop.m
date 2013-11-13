//
//  Shop.m
//  SmartShop
//
//  Created by Batman on 10/11/2013.
//  Copyright (c) 2013 Batman. All rights reserved.
//

#import "GoogleAPIShop.h"

@implementation GoogleAPIShop

@synthesize SName;
@synthesize location;
@synthesize reference;
@synthesize photosArray;

-(id)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"%@ %f %f %@ %@",
            SName,
            location.lat,
            location.lng,
            [reference substringWithRange:NSMakeRange(0, 4)],
            photosArray,
            nil];
}

@end
