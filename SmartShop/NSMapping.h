//
//  NSMapping.h
//  SmartShop
//
//  Created by Batman on 10/11/2013.
//  Copyright (c) 2013 Batman. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMapping : NSObject
// The function which creates objects from a json based on the class, mapping and json turned into dict
+(id)makeObject:(Class)classType WithMapping:(NSDictionary *)mapping fromJSON:(NSDictionary *)jsonDict;

@end
