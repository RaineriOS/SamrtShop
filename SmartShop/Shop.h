//
//  Shop.h
//  SmartShop
//
//  Created by Batman on 13/11/2013.
//  Copyright (c) 2013 Batman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Post;

// This class is used to save the shop's detail locally in order to
// avoid sending requests to the server every time something new is created
@interface Shop : NSManagedObject

@property (nonatomic, retain) NSNumber * lat;
@property (nonatomic, retain) NSNumber * lng;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * shop_id;
@property (nonatomic, retain) NSSet *post_relationship;
@end

@interface Shop (CoreDataGeneratedAccessors)

- (void)addPost_relationshipObject:(Post *)value;
- (void)removePost_relationshipObject:(Post *)value;
- (void)addPost_relationship:(NSSet *)values;
- (void)removePost_relationship:(NSSet *)values;

@end
