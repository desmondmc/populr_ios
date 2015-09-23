//
//  SPSettingsViewController.m
//  gzelle
//
//  Created by Desmond McNamee on 2015-05-27.
//  Copyright (c) 2015 Speedl. All rights reserved.
//

#import "SPSettingsViewController.h"
#import "SPComposeViewController.h"
#import "SPFriendFindingViewController.h"

@interface SPSettingsViewController ()
@property (strong, nonatomic) IBOutlet UILabel *usernameLabel;
@property (strong, nonatomic) SPComposeViewController *feedbackViewController;
@property (strong, nonatomic) IBOutlet UILabel *doneLabel;

@end

@implementation SPSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupAppearance];
}

- (void) setupAppearance {
    [self.view setBackgroundColor:[SPAppearance globalBackgroundColour]];
    _usernameLabel.text = [[SPUser currentUser] username];
    [self.doneLabel setTextColor:[SPAppearance globalBackgroundColour]];
}
- (IBAction)onFeedbackPress:(id)sender {
    [[self navigationController] pushViewController:[self feedbackViewController] animated:YES];
}

- (SPComposeViewController *)feedbackViewController {
    if (!_feedbackViewController) {
        _feedbackViewController = [[SPComposeViewController alloc] initWithIsFeedback:YES];
        _feedbackViewController.view.backgroundColor = [SPAppearance globalBackgroundColour];
    }
    return _feedbackViewController;
}

- (IBAction)onLogoutPress:(id)sender {
    [[SPUser currentUser] logoutUserInBackgroundWithBlock:^(BOOL success, NSString *serverMessage) {
        if (success) {
            [SPLoginRouter gotoLoggedOutView];
        } else {
            [SPNotification showErrorNotificationWithMessage:@"Error on logout."
                                            inViewController:self];
        }
    }];
    
}
- (IBAction)onBackPress:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)onPhonePress:(id)sender {
    [[self navigationController] pushViewController:[SPFriendFindingViewController new]
                                           animated:YES];
}
@end
