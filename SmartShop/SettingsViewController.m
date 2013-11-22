//
//  SettingsViewController.m
//  SmartShop
//
//  Created by Batman on 22/11/2013.
//  Copyright (c) 2013 Batman. All rights reserved.
//

#import "SettingsViewController.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

// TODO fix it for when application comes from background
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self updateViewFromUserDefaults];
    // When the view of the app is clicked, remove the keyboard if it is active
    UITapGestureRecognizer *resigneKeyboardTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resignKeyboard:)];
    resigneKeyboardTapRecognizer.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:resigneKeyboardTapRecognizer];
}

-(void)viewWillAppear:(BOOL)animated
{
    [self updateViewFromUserDefaults];
    [super viewWillAppear:animated];
}

-(void) updateViewFromUserDefaults
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    self.nameTextField.text = [userDefaults valueForKey:@"name"];
    self.usernameTextField.text = [userDefaults valueForKey:@"username"];
    BOOL isSelected = [userDefaults boolForKey:@"showFriends"];
    self.showFriends.on = isSelected;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)saveSettings:(id)sender
{
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setValue:self.nameTextField.text forKey:@"name"];
    [userDefaults setValue:self.usernameTextField.text forKey:@"username"];
    NSNumber *isSelected = [[NSNumber alloc] initWithBool:self.showFriends.on];
    NSLog(@"%@", isSelected);
    [userDefaults setValue:isSelected forKey:@"showFriends"];
    [userDefaults synchronize];
    
    [self.nameTextField resignFirstResponder];
    [self.usernameTextField resignFirstResponder];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}


-(void)resignKeyboard:(UIGestureRecognizer *)getureRecognizer
{
    [self.nameTextField resignFirstResponder];
    [self.usernameTextField resignFirstResponder];
}
@end
