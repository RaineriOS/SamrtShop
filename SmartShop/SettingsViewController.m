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

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    self.nameTextField.text = [userDefaults valueForKey:@"name"];
    self.usernameTextField.text = [userDefaults valueForKey:@"username"];
	// Do any additional setup after loading the view.
    
    // When the view of the app is clicked, remove the keyboard if it is active
    UITapGestureRecognizer *resigneKeyboardTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resignKeyboard:)];
    resigneKeyboardTapRecognizer.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:resigneKeyboardTapRecognizer];
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
