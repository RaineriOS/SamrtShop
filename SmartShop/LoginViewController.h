//
//  LonginViewController.h
//  SmartShop
//
//  Created by Batman on 13/11/2013.
//  Copyright (c) 2013 Batman. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController

// The name of the user
@property (strong, nonatomic) IBOutlet UITextField *nameTextField;
// The username of the user
@property (strong, nonatomic) IBOutlet UITextField *usernameTextField;

// Save user information in the user defaults
- (IBAction)saveUserInfo:(id)sender;

@end
