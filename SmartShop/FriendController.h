//
//  FriendController.h
//  SmartShop
//
//  Created by Batman on 22/11/2013.
//  Copyright (c) 2013 Batman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UpdateViewDelegate.h"

@interface FriendController : NSObject

@property (strong, nonatomic) NSMutableArray *friendsArr;
@property (weak, nonatomic) id<UpdateViewDelegate> delegate;

// search for freinds by requesting the server and retrieving their location
// and parsing it into UserFromJSON object and adding it to the friendArr
-(void)searchForFriends;

@end
