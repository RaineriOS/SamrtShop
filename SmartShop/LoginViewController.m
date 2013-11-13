//
//  LonginViewController.m
//  SmartShop
//
//  Created by Batman on 13/11/2013.
//  Copyright (c) 2013 Batman. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

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
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)saveUserInfo:(id)sender
{
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setValue:self.nameTextField.text forKey:@"name"];
    [userDefaults setValue:self.usernameTextField.text forKey:@"username"];
    [userDefaults synchronize];
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
