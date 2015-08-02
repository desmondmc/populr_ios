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
        [SPNotification showErrorNotificationWithMessage:validationErrorMessage inViewController:self];
        return;
    }
    [self routeBasedOnSegmentControl];
}

- (void) routeBasedOnSegmentControl {
    if (self.segmentControl.selectedSegmentIndex == 0) {    //Register
        [self registerUser];
    } else {                                                //Login
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
    [SPUser signUpUserInBackgroundWithUsername:lowercaseUsername password:_passwordField.text block:^(SPUser *user, NSString* message) {
        _nextButton.enabled = YES;
        if (user == nil && message != nil) {
            [SPNotification showErrorNotificationWithMessage:message inViewController:self];
            return;
        }
        
        [SPLoginRouter gotoLoggedInViewAndShowMessages:NO];
    }];
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
    NSString *uppercaseUsername = [_usernameField.text lowercaseString];
    _nextButton.enabled = NO;
    [SPUser loginUserInBackgroundWithUsername:uppercaseUsername password:_passwordField.text block:^(SPUser *user, NSString* message) {
        _nextButton.enabled = YES;
        if (user == nil && message != nil) {
            [SPNotification showErrorNotificationWithMessage:message inViewController:self];
            return;
        }
        
        [SPLoginRouter gotoLoggedInViewAndShowMessages:NO];
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
