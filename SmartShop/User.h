//
//  User.h
//  SmartShop
//
//  Created by Batman on 13/11/2013.
//  Copyright (c) 2013 Batman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Post;

@interface User : NSManagedObject

@property (nonatomic, retain) NSNumber * current_lat;
@property (nonatomic, retain) NSNumber * current_lng;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * user_id;
@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSSet *post_relationship;
@end

@interface User (CoreDataGeneratedAccessors)

- (void)addPost_relationshipObject:(Post *)value;
- (void)removePost_relationshipObject:(Post *)value;
- (void)addPost_relationship:(NSSet *)values;
- (void)removePost_relationship:(NSSet *)values;

@end
