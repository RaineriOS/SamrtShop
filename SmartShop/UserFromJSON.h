//
//  UserFromJSON.h
//  SmartShop
//
//  Created by Batman on 22/11/2013.
//  Copyright (c) 2013 Batman. All rights reserved.
//

#import <Foundation/Foundation.h>

// The model returned from the server is represented by this
@interface UserFromJSON : NSObject

@property (nonatomic) double currentLat;
@property (nonatomic) double currentLng;
@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSString * username;

@end
