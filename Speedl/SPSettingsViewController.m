//
//  SPSettingsViewController.m
//  gzelle
//
//  Created by Desmond McNamee on 2015-05-27.
//  Copyright (c) 2015 Speedl. All rights reserved.
//

#import "SPSettingsViewController.h"

@interface SPSettingsViewController ()
@property (strong, nonatomic) IBOutlet UILabel *usernameLabel;

@end

@implementation SPSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupAppearance];
}

- (void) setupAppearance {
    [self.view setBackgroundColor:[SPAppearance globalBackgroundColour]];
    _usernameLabel.text = [[SPUser currentUser] username];
}

- (IBAction)onLogoutPress:(id)sender {
    [SPLoginRouter gotoLoggedOutView];
}
- (IBAction)onBackPress:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
