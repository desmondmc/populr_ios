//
//  SPSettingsViewController.m
//  gzelle
//
//  Created by Desmond McNamee on 2015-05-27.
//  Copyright (c) 2015 Speedl. All rights reserved.
//

#import "SPSettingsViewController.h"
#import "SPComposeViewController.h"
#import "SPPhoneNumberViewController.h"
#import "SPFriendFindingViewController.h"

@interface SPSettingsViewController ()
@property (strong, nonatomic) IBOutlet UILabel *usernameLabel;
@property (strong, nonatomic) SPComposeViewController *feedbackViewController;
@property (strong, nonatomic) SPPhoneNumberViewController *phoneViewController;
@property (strong, nonatomic) SPFriendFindingViewController *friendsFindingViewController;
@property (strong, nonatomic) IBOutlet UILabel *doneLabel;

@end

@implementation SPSettingsViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setupAppearance];
}

- (void) setupAppearance {
    [self.view setBackgroundColor:[SPAppearance getMainBackgroundColour]];
    [self.doneLabel setTextColor:[SPAppearance getMainBackgroundColour]];
    _usernameLabel.text = [[SPUser currentUser] username];
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

- (SPPhoneNumberViewController *)phoneViewController {
    if (!_phoneViewController) {
        _phoneViewController = [[SPPhoneNumberViewController alloc] initWithType:SPPhoneNumberViewTypeNavigation];
    }
    return _phoneViewController;
}

- (SPFriendFindingViewController *)friendsFindingViewController {
    if (!_friendsFindingViewController) {
        _friendsFindingViewController = [SPFriendFindingViewController new];
    }
    return _friendsFindingViewController;
}

- (IBAction)onLogoutPress:(id)sender {
    [[SPUser currentUser] logoutUserInBackgroundWithBlock:^(BOOL success, NSString *serverMessage) {
        // Don't check for success here. Should still logout even on failure.
    }];
    
    [SPUser clearWatchData];
    [SPLoginRouter gotoLoggedOutView];
    
}
- (IBAction)onBackPress:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)onPhonePress:(id)sender {
    [[self navigationController] pushViewController:[self phoneViewController] animated:YES];
}

- (IBAction)onFindFriendsPress:(id)sender {
    [[self navigationController] pushViewController:[self friendsFindingViewController] animated:YES];
}

@end
