//
//  Post.h
//  SmartShop
//
//  Created by Batman on 13/11/2013.
//  Copyright (c) 2013 Batman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Shop, User;

@interface Post : NSManagedObject

@property (nonatomic, retain) NSNumber * burning;
@property (nonatomic, retain) NSNumber * cold;
@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSNumber * cool;
@property (nonatomic, retain) NSNumber * freezing;
@property (nonatomic, retain) NSNumber * hot;
@property (nonatomic, retain) NSString * image_name;
@property (nonatomic, retain) NSNumber * post_id;
@property (nonatomic, retain) NSNumber * shop_id;
@property (nonatomic, retain) NSNumber * user_id;
@property (nonatomic, retain) Shop *shop_relationship;
@property (nonatomic, retain) User *user_relationship;

@end
