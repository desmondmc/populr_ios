//
//  SPSignupViewController.m
//  Speedle
//
//  Created by Desmond McNamee on 2015-03-17.
//  Copyright (c) 2015 Desmond McNamee. All rights reserved.
//

#import "SPSignupViewController.h"

@interface SPSignupViewController ()

@end

@implementation SPSignupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onSignupPress:(id)sender {
    [SPUser signUpUserInBackgroundWithUsername:@"NewGuy" password:@"password" andBlock:^(SPUser *user, NSError *error) {
        NSLog(@"Completed Request.");
    }];
}

- (IBAction)onLoginPress:(id)sender {
    [SPUser loginUserInBackgroundWithUsername:@"NewGuy" password:@"password" andBlock:^(SPUser *user, NSError *error) {
        user = [SPUser currentUser];
        NSLog(@"Completed Request.");
        [SPUser logoutCurrentUser];
        NSLog(@"Logged out.");
    }];
}

@end
