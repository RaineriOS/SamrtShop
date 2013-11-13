//
//  Shop.h
//  SmartShop
//
//  Created by Batman on 10/11/2013.
//  Copyright (c) 2013 Batman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Location.h"

@interface GoogleAPIShop : NSObject

@property (strong, nonatomic) NSString *SName;
@property (strong, nonatomic) NSString *reference;
@property (strong, nonatomic) NSArray *photosArray;

@property (strong, nonatomic) Location *location;

@end
