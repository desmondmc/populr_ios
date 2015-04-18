//
//  SPComposeViewController.m
//  Speedle
//
//  Created by Desmond McNamee on 2015-03-15.
//  Copyright (c) 2015 Desmond McNamee. All rights reserved.
//

#import "SPComposeViewController.h"

@interface SPComposeViewController ()
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *micButtonBottomConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *sendButtonBottomConstraint;
@property (strong, nonatomic) IBOutlet UITextView *messageTextView;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *textFieldTopConstraint;
@property (strong, nonatomic) IBOutlet UIButton *sendButton;

@end

@implementation SPComposeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [_messageTextView becomeFirstResponder];
    
    // Listen for keyboard appearances and disappearances
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    [self setupAppearance];
    
}
- (void) setupAppearance {
    [self.sendButton styleAsMainSpeedlButton];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [_messageTextView becomeFirstResponder];
}
- (IBAction)onMicPress:(id)sender {
    [[SPUser currentUser] getMessagesInBackground:^(NSArray *messages, NSString *serverMessage) {
        for (SPMessage *message in messages) {
            NSLog(@"%@", message.body);
        }
    }];
}

-(void)keyboardWasShown:(NSNotification*)notification
{
    [self.view layoutIfNeeded];
    NSDictionary* keyboardInfo = [notification userInfo];
    NSValue* keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameBeginUserInfoKey];
    CGFloat keyboardHeight = [keyboardFrameBegin CGRectValue].size.height;
    
    _micButtonBottomConstraint.constant = keyboardHeight + 20;
    _sendButtonBottomConstraint.constant = keyboardHeight + 20;
    
    [UIView animateWithDuration:0.5
                     animations:^{
                         [self.view layoutIfNeeded]; // Called on parent view
    }];
    
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (IBAction)onGoLeftPress:(id)sender {
    [self.containerViewController goToMessageViewController];
}

- (IBAction)onGoRightPress:(id)sender {
    [self.containerViewController goToFriendsViewController];
}

#pragma mark - UITextViewDelegate

#define kPlaceHolderText @"Start typing..."

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:kPlaceHolderText]) {
        textView.text = @"";
        textView.textColor = [SPAppearance mainTextFieldColour];
    }
    [textView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@""]) {
        textView.text = kPlaceHolderText;
        textView.textColor = [SPAppearance seeThroughColour];
    }
    [textView resignFirstResponder];
}

#pragma mark - SPContainterViewDelegate

- (void) newVisableViewController:(UIViewController *)viewController {
    if (viewController == self) {
        [_messageTextView becomeFirstResponder];
        NSLog(@"ComposeView is visable!!");
    }
}

@end
