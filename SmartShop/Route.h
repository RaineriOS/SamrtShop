//
//  Route.h
//  SmartShop
//
//  Created by Batman on 10/11/2013.
//  Copyright (c) 2013 Batman. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Route : NSObject

@property (strong, nonatomic) NSString *copyrights;
@property (strong, nonatomic) NSArray *warnings;
@property (strong, nonatomic) NSString *overviewPolylinePointsEncoded;
@property (strong, nonatomic) NSArray *legsArray;

@end
