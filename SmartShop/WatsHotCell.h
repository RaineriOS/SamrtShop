//
//  WatsHotCell.h
//  SmartShop
//
//  Created by Batman on 21/11/2013.
//  Copyright (c) 2013 Batman. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "UpdateViewDelegate.h"
#import "PostFromJSON.h"

@interface WatsHotCell : UICollectionViewCell

@property (strong, nonatomic) PostFromJSON *post;
@property (strong, nonatomic) NSNumber *postId;
@property (weak, nonatomic) id<UpdateViewDelegate> delegate;
@property (strong, nonatomic) IBOutlet UILabel *contentLabel;
@property (strong, nonatomic) IBOutlet UIImageView *locationImageView;
@property (strong, nonatomic) IBOutlet UILabel *shopNameLabel;
@property (strong, nonatomic) IBOutlet UIImageView *clothImageView;
@property (strong, nonatomic) IBOutlet UILabel *hotLabel;
@property (strong, nonatomic) IBOutlet UILabel *coolLabel;
@property (strong, nonatomic) IBOutlet UILabel *freezingLabel;

- (IBAction)hotAction:(id)sender;
- (IBAction)coolAction:(id)sender;
- (IBAction)freezingAction:(id)sender;
@end
