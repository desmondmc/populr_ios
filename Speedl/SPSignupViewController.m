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
@property (strong, nonatomic) IBOutlet UIButton *nextButton;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *nextButtonBottomContraint;
@property (strong, nonatomic) IBOutlet UISegmentedControl *segmentControl;

@end

@implementation SPSignupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardDidShowNotification object:nil];
    [_usernameField becomeFirstResponder];
    [self setupAppearance];
}

- (void) setupAppearance {
    [self.view setBackgroundColor:[SPAppearance globalBackgroundColour]];
    [self.usernameField styleAsMainSpeedlTextField];
    [self.passwordField styleAsMainSpeedlTextField];
    [self.nextButton styleAsMainSpeedlButton];
    [self.segmentControl styleAsMainSpeedlSegmentControl];
}

-(void)keyboardWasShown:(NSNotification*)notification
{
    CGFloat height = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    
    self.nextButtonBottomContraint.constant = height + 20;
    [self.view layoutIfNeeded];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)onNextPress:(id)sender {
    NSString *validationErrorMessage = [self validateLocally];
    if (validationErrorMessage) {
        [self showErrorNotificationWithMessage:validationErrorMessage];
        return;
    }
    [self routeBasedOnSegmentControl];
}

- (void) routeBasedOnSegmentControl {
    if (self.segmentControl.selectedSegmentIndex == 0) {    //Login
        [self loginUser];
    } else {                                                //Register
        [self registerUser];
    }
}

- (void)registerUser {
    [SPLoginRouter gotoLoggedInView];
    
//    [SPUser signUpUserInBackgroundWithUsername:@"NewGuy" password:@"password" block:^(SPUser *user, NSString* message) {
//        if (user == nil && message != nil) {
//            [self showErrorNotificationWithMessage:message];
//            return;
//        }
//        
//        [SPLoginRouter gotoLoggedInView];
//    }];
    
    
}



- (void) loginUser {
    [SPLoginRouter gotoLoggedInView];
    
    
//    [SPUser loginUserInBackgroundWithUsername:@"NewGuy" password:@"password" block:^(SPUser *user, NSString* message) {
//        user = [SPUser currentUser];
//        NSLog(@"Completed Request.");
//        [SPUser logoutCurrentUser];
//        NSLog(@"Logged out.");
//    }];
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
                                   tintColor:[SPAppearance seeThroughColour]
                                       image:[CSNotificationView imageForStyle:CSNotificationViewStyleError]
                                     message:message
                                    duration:kCSNotificationViewDefaultShowDuration];
    
//    [CSNotificationView showInViewController:self
//                                       style:CSNotificationViewStyleError
//                                     message:message];
    
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
