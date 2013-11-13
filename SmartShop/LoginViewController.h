//
//  LonginViewController.h
//  SmartShop
//
//  Created by Batman on 13/11/2013.
//  Copyright (c) 2013 Batman. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController

@property (strong, nonatomic) IBOutlet UITextField *nameTextField;
@property (strong, nonatomic) IBOutlet UITextField *usernameTextField;

- (IBAction)saveUserInfo:(id)sender;

@end
