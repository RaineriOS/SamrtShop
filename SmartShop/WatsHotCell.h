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

// The model for the cells

@interface WatsHotCell : UICollectionViewCell

// Store the post which this cell represents, it is used to
// update the information of the cell, can be optimised later
@property (strong, nonatomic) PostFromJSON *post;
@property (strong, nonatomic) NSNumber *postId; // not needed
@property (weak, nonatomic) id<UpdateViewDelegate> delegate; // delegate  for updating collection view
@property (strong, nonatomic) IBOutlet UILabel *contentLabel;
@property (strong, nonatomic) IBOutlet UIImageView *locationImageView;
@property (strong, nonatomic) IBOutlet UILabel *shopNameLabel;
@property (strong, nonatomic) IBOutlet UIImageView *clothImageView;
@property (strong, nonatomic) IBOutlet UILabel *hotLabel;
@property (strong, nonatomic) IBOutlet UILabel *coolLabel;
@property (strong, nonatomic) IBOutlet UILabel *freezingLabel;

// Action which update the serverside db and the collection view when the buttons are pressed
- (IBAction)hotAction:(id)sender;
- (IBAction)coolAction:(id)sender;
- (IBAction)freezingAction:(id)sender;
@end
