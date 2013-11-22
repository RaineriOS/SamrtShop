//
//  WatsHotCell.m
//  SmartShop
//
//  Created by Batman on 21/11/2013.
//  Copyright (c) 2013 Batman. All rights reserved.
//

#import "WatsHotCell.h"
#import <SBJson.h>

@implementation WatsHotCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/


// TODO remove the link to post
-(void)postJsonString:(NSString *)jsonString
{
    NSData *putData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSString *putLength = [NSString stringWithFormat:@"%d", [putData length]];
    NSString *urlString = @"http://localhost:3000/post";
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"PUT"];
    [request setValue:putLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/json;charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    
    [request setHTTPBody:putData];
    // send the request (submit the form) and get the response
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSString *returnString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
    
    NSLog(@"%@", returnString);
    if ([self.delegate respondsToSelector:@selector(updateView)]) {
        [self.delegate updateView];
    }
}

- (IBAction)hotAction:(id)sender
{
    SBJsonWriter *jsonWriter = [[SBJsonWriter alloc] init];
    NSString *jsonString = [jsonWriter stringWithObject:@{
                                                      @"id":[NSString stringWithFormat:@"%@", self.postId],
                                                      @"field": @"hot"
                                                      }];
    int value = [self.post.hot intValue];
    self.post.hot = [NSNumber numberWithInt:value + 1];
    [self postJsonString:jsonString];
}

- (IBAction)coolAction:(id)sender
{
    SBJsonWriter *jsonWriter = [[SBJsonWriter alloc] init];
    NSString *jsonString = [jsonWriter stringWithObject:@{
                                                      @"id":[NSString stringWithFormat:@"%@", self.postId],
                                                      @"field": @"cool"
                                                      }];
    int value = [self.post.cool intValue];
    self.post.cool = [NSNumber numberWithInt:value + 1];
    [self postJsonString:jsonString];
}

- (IBAction)freezingAction:(id)sender
{
    SBJsonWriter *jsonWriter = [[SBJsonWriter alloc] init];
    NSString *jsonString = [jsonWriter stringWithObject:@{
                                                      @"id":[NSString stringWithFormat:@"%@", self.postId],
                                                      @"field": @"freezing"
                                                      }];
    int value = [self.post.freezing intValue];
    self.post.freezing = [NSNumber numberWithInt:value + 1];

    
    [self postJsonString:jsonString];
}
@end
