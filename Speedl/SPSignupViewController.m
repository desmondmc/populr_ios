//
//  SPSignupViewController.m
//  Speedle
//
//  Created by Desmond McNamee on 2015-03-17.
//  Copyright (c) 2015 Desmond McNamee. All rights reserved.
//

#import "SPSignupViewController.h"

@interface SPSignupViewController ()
@property (strong, nonatomic) IBOutlet UITextField *usernameField;
@property (strong, nonatomic) IBOutlet UITextField *passwordField;

@end

@implementation SPSignupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [_usernameField becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)onSignupPress:(id)sender {
    NSString *validationErrorMessage = [self validateLocally];
    if (validationErrorMessage) {
        [self showErrorNotificationWithMessage:validationErrorMessage];
        return;
    }
    
    [SPUser signUpUserInBackgroundWithUsername:@"NewGuy" password:@"password" block:^(SPUser *user, NSString* message) {
        if (user == nil && message != nil) {
            [self showErrorNotificationWithMessage:message];
            return;
        }
        
        [SPLoginRouter gotoLoggedInView];
    }];
}

- (IBAction)onLoginPress:(id)sender {
    [SPUser loginUserInBackgroundWithUsername:@"NewGuy" password:@"password" block:^(SPUser *user, NSString* message) {
        user = [SPUser currentUser];
        NSLog(@"Completed Request.");
        [SPUser logoutCurrentUser];
        NSLog(@"Logged out.");
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

- (void) showErrorNotificationWithMessage:(NSString *)message{
    [CSNotificationView showInViewController:self
                                       style:CSNotificationViewStyleError
                                     message:message];
    
}

#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == _usernameField) {
        [_passwordField becomeFirstResponder];
    } else if (textField == _passwordField){
        [self onSignupPress:nil];
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
