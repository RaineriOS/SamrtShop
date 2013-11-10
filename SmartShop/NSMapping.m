//
//  NSMapping.m
//  SmartShop
//
//  Created by Batman on 10/11/2013.
//  Copyright (c) 2013 Batman. All rights reserved.
//

#import "NSMapping.h"

@implementation NSMapping

+(id)makeObject:(Class)classType WithMapping:(NSDictionary *)mapping fromJSON:(NSDictionary *)jsonDict
{
    id object = [[classType alloc] init];
    for (NSString *prop in [mapping allKeys]) {
        NSArray *pathToObject = [prop componentsSeparatedByString:@"."];
        id currentItem = jsonDict;
        for (NSString *key in pathToObject) {
            currentItem = [currentItem objectForKey:key];
        }
        id key = [mapping objectForKey:prop];
        if ([key isKindOfClass:[NSDictionary class]]) {
            if ([currentItem isKindOfClass:[NSArray class]]) {
                NSMutableArray *objectsArray = [[NSMutableArray alloc] init];
                for (NSDictionary *childDict in currentItem) {
                    id childObject = [NSMapping makeObject:[key objectForKey:@"class"] WithMapping:[key objectForKey:@"mapping"] fromJSON:childDict];
                    [objectsArray addObject:childObject];
                }
                [object setValue:objectsArray forKey:[key objectForKey:@"property"]];
            } else {
                id childObject = [NSMapping makeObject:[key objectForKey:@"class"] WithMapping:[key objectForKey:@"mapping"] fromJSON:currentItem];
                [object setValue:childObject forKey:[key objectForKey:@"property"]];
            }
        } else {
            if (currentItem != nil) {
                [object setValue:currentItem forKey:key];
            }
        }
    }
    return object;
}

@end
