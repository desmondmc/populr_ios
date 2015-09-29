//
//  SPSignupViewController.m
//  Speedle
//
//  Created by Desmond McNamee on 2015-03-17.
//  Copyright (c) 2015 Desmond McNamee. All rights reserved.
//

#import "SPSignupViewController.h"
#import "SPDeviceToken.h"

@interface SPSignupViewController ()
@property (strong, nonatomic) IBOutlet UITextField *usernameField;
@property (strong, nonatomic) IBOutlet UITextField *passwordField;
@property (strong, nonatomic) IBOutlet UIButton *nextButton;
@property (strong, nonatomic) IBOutlet UIView *tabContainerView;
@property (strong, nonatomic) SPCustomTabView *customTabView;
@property (strong, nonatomic) IBOutlet UILabel *nextButtonLabel;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation SPSignupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [_usernameField becomeFirstResponder];
    
    [self setupAppearance];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidAppear:(BOOL)animated {
    [SPUser logoutCurrentUser];
}

- (void) setupAppearance {
    [self.view setBackgroundColor:[SPAppearance globalBackgroundColour]];
    [self.usernameField styleAsMainSpeedlTextField];
    [self.passwordField styleAsMainSpeedlTextField];
    [self.nextButtonLabel styleAsSendLabel];
    [self.activityIndicator setColor:[SPAppearance globalBackgroundColour]];
    
    [self notLoadingState];
    [_tabContainerView addSubview:[self customTabView]];
    [SPAutoLayout constrainSubviewToFillSuperview:[self customTabView]];
}

- (SPCustomTabView *)customTabView {
    if (!_customTabView) {
        _customTabView = [[SPCustomTabView alloc] initWithTabViewType:SPTabViewTypeLogin];
        [_customTabView setSelectedSegmentIndex:0];
    }
    return _customTabView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)onNextPress:(id)sender {
    NSString *validationErrorMessage = [self validateLocally];
    if (validationErrorMessage) {
        [SPNotification showErrorNotificationWithMessage:validationErrorMessage inViewController:self];
        return;
    }
    [self routeBasedOnSegmentControl];
}

- (void) routeBasedOnSegmentControl {
    if ([self customTabView].selectedSegmentIndex == 0) {    //Register
        [self registerUser];
    } else {                                                 //Login
        [self loginUser];
    }
}

- (void)registerUser {
    NSString *lowercaseUsername = [_usernameField.text lowercaseString];
    BOOL validationSuccess = [self localValidationOfNewUsername:lowercaseUsername];
    if (!validationSuccess) {
        return;
    }
    _nextButton.enabled = NO;
    [self loadingState];
    [SPUser signUpUserInBackgroundWithUsername:lowercaseUsername password:_passwordField.text block:^(SPUser *user, NSString* message) {
        [self notLoadingState];
        _nextButton.enabled = YES;
        if (user == nil && message != nil) {
            [SPNotification showErrorNotificationWithMessage:message inViewController:self];
            return;
        }
        
        // If the user has logged out and then signed up for a new account we need to send up the device token again.
        [self sendExistingDeviceTokenIfNeeded];
        
        [SPLoginRouter gotoLoggedInViewAndNewUser:YES];
    }];
}

- (void)sendExistingDeviceTokenIfNeeded {
    NSString *existingDeviceToken = [SPDeviceToken getStoredDeviceToken];
    if (existingDeviceToken && ![existingDeviceToken isEqualToString:@""]) {
        [[SPUser currentUser] postDeviceTokenInBackground:existingDeviceToken block:nil];
    }
}

- (BOOL)localValidationOfNewUsername:(NSString *)newUsername {
    if ([newUsername containsString:@" "]) {
        [SPNotification showErrorNotificationWithMessage:@"No spaces, idiot." inViewController:self];
        return NO;
    } else if ([newUsername isIncludingEmoji]) {
        [SPNotification showErrorNotificationWithMessage:@"Sorry no Emojis. 😢" inViewController:self];
        return NO;
    }
    return YES;
}



- (void) loginUser {
    [self loadingState];
    NSString *uppercaseUsername = [_usernameField.text lowercaseString];
    _nextButton.enabled = NO;
    [SPUser loginUserInBackgroundWithUsername:uppercaseUsername password:_passwordField.text block:^(SPUser *user, NSString* message) {
        [self notLoadingState];
        _nextButton.enabled = YES;
        if (user == nil && message != nil) {
            [SPNotification showErrorNotificationWithMessage:message inViewController:self];
            return;
        }
        
        // If the user has logged out and then logged into a new account we need to send up the device token again.
        [self sendExistingDeviceTokenIfNeeded];
        
        [SPLoginRouter gotoLoggedInViewAndNewUser:NO];
    }];
}

- (NSString *) validateLocally {
    if ([_usernameField.text isEqualToString:@""] || _usernameField.text == nil) {
        //Error please enter a username.
        return @"Please Enter a username";

    }
    if ([_passwordField.text isEqualToString:@""] || _passwordField.text == nil) {
        //Error please enter password
        return @"Please Enter a password";
    }
    
    return nil;
}

- (void)loadingState {
    [_nextButtonLabel setHidden:YES];
    [_activityIndicator startAnimating];
    [_activityIndicator setHidden:NO];
}

- (void)notLoadingState {
    [_nextButtonLabel setHidden:NO];
    [_activityIndicator setHidden:YES];
}

#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == _usernameField) {
        [_passwordField becomeFirstResponder];
    } else if (textField == _passwordField){
        [self routeBasedOnSegmentControl];
    }
    return YES;
}

#pragma mark AFDropdownNotificationDelegate

-(void)dropdownNotificationTopButtonTapped {
    
    NSLog(@"Top button tapped");
}

-(void)dropdownNotificationBottomButtonTapped {
    
    NSLog(@"Bottom button tapped");
}

@end
