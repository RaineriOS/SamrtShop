//
//  SettingsViewController.h
//  SmartShop
//
//  Created by Batman on 22/11/2013.
//  Copyright (c) 2013 Batman. All rights reserved.
//

#import <UIKit/UIKit.h>

// The view controller for the setting whcih are stored in the userdefaults
@interface SettingsViewController : UIViewController <UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UITextField *nameTextField;
@property (strong, nonatomic) IBOutlet UITextField *usernameTextField;

// Save the setting into the userdefauls
- (IBAction)saveSettings:(id)sender;

@end
