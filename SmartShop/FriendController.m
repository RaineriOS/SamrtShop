//
//  FriendController.m
//  SmartShop
//
//  Created by Batman on 22/11/2013.
//  Copyright (c) 2013 Batman. All rights reserved.
//

#import "FriendController.h"
#import <MapKit/MapKit.h>

#import "NSMapping.h"
#import "UserFromJSON.h"

@implementation FriendController

@synthesize friendsArr;


-(id)init
{
    self = [super init];
    if (self) {
        friendsArr = [[NSMutableArray alloc] init];
    }
    return self;
}


-(void)searchForFriends
{
    // The address entered
    NSOperationQueue *downloadQueue = [[NSOperationQueue alloc] init];
    downloadQueue.name = @"download_queue";
    [downloadQueue addOperationWithBlock:^{
        // Perform geocoding
        // Send a synchronous request
        NSString *jsonPath = @"http://localhost:3000/user";
        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:jsonPath]];
        NSURLResponse *returingResponse = nil;
        NSError *connError = nil;
        NSData * responseData = [NSURLConnection sendSynchronousRequest:urlRequest
                                                      returningResponse:&returingResponse
                                                                  error:&connError];
        if (connError == nil)
        {
            //parse out the json data
            NSError* error;
            NSDictionary* json = [NSJSONSerialization
                                  JSONObjectWithData:responseData // 1
                                  options:kNilOptions
                                  error:&error];
            NSDictionary *userMapping = [[NSDictionary alloc] initWithObjectsAndKeys:
                                         @"name", @"name",
                                         @"username", @"username",
                                         @"currentLat", @"current_lat",
                                         @"currentLng", @"current_lng",
                                         nil];
            [friendsArr removeAllObjects];
            for (NSDictionary *userDict in [json objectForKey:@"results"]) {
                UserFromJSON *newUser = [NSMapping makeObject:[UserFromJSON class]
                                                  WithMapping:userMapping fromJSON:userDict];
                [friendsArr addObject:newUser];
            }
            if ([self.delegate respondsToSelector:@selector(updateView)]) {
                [self.delegate updateView];
            }
        }
    }];
}
@end
