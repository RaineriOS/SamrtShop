//
//  Photo.m
//  SmartShop
//
//  Created by Batman on 10/11/2013.
//  Copyright (c) 2013 Batman. All rights reserved.
//

#import "Photo.h"

@implementation Photo

@synthesize reference;
@synthesize height;
@synthesize width;

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"%@ %i %i",
            [reference substringWithRange:NSMakeRange(0, 4)],
            width,
            height,
            nil];
}

@end
