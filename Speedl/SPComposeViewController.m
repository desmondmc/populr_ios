//
//  SPComposeViewController.m
//  Speedle
//
//  Created by Desmond McNamee on 2015-03-15.
//  Copyright (c) 2015 Desmond McNamee. All rights reserved.
//

#import "SPComposeViewController.h"

#define kPlaceHolderText @"Write something..."

@interface SPComposeViewController ()

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *sendButtonBottomConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *messageTopConstraint;
@property (strong, nonatomic) IBOutlet UITextView *messageTextView;

@property (strong, nonatomic) IBOutlet UIButton *sendButton;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *sendActivityIndicator;
@property (nonatomic) CGFloat currentKeyboardHeight;
@property (strong, nonatomic) IBOutlet UIButton *backButton;
@property (strong, nonatomic) IBOutlet UIImageView *backButtonImage;
@property (strong, nonatomic) NSString *placeHolderText;
@property (nonatomic) BOOL isFeedBackView;

@end

@implementation SPComposeViewController

- (id)initWithIsFeedback:(BOOL)isFeedbackView {
    self = [super init];
    if (self) {
        _isFeedBackView = isFeedbackView;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupAppearance];
}

- (void)viewWillAppear:(BOOL)animated {
    // Listen for keyboard appearances and disappearances
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) setupAppearance {
    self.view.backgroundColor = [SPAppearance getSecondColourForToday];
    [self notSendingState];
    [self.sendButton styleAsMainSpeedlButton];
    [self.messageTextView styleAsMainSpeedlTextView];
    
    self.messageTextView.textColor = [SPAppearance seeThroughColour];
    
    [self keyboardWillHide:nil];
    
    if (_isFeedBackView) {
        [self setupForFeedback];
    } else {
        _placeHolderText = kPlaceHolderText;
        self.messageTextView.text = _placeHolderText;
    }
    

}

- (void)setupForFeedback {
    _backButton.hidden = NO;
    _backButtonImage.hidden = NO;
    _placeHolderText = @"Give us some feeback :)";
    self.messageTextView.text = _placeHolderText;
}

- (IBAction)onSendPress:(id)sender {
    
    if ([_messageTextView.text isEqualToString:_placeHolderText] || [_messageTextView.text isEqualToString:@""]) {
        [SPNotification showErrorNotificationWithMessage:[self getNoMessageErrorString]
                                        inViewController:self];
        return;
    }
    
    [self sendingState];
    if (!_isFeedBackView) {
        [self sendMessage];
    } else {
        [self sendFeedback];
    }
}

- (NSString *)getNoMessageErrorString {
    if (_isFeedBackView) {
        return @"type something...";
    } else {
        return @"Type a message, kid.";
    }
}

- (void)sendMessage {
    [[SPUser currentUser] postMessageInBackground:_messageTextView.text block:^(BOOL success, NSString *serverMessage) {
        [self notSendingState];
        if (!success) {
            [SPNotification showErrorNotificationWithMessage:serverMessage inViewController:self];
        } else {
            [_messageTextView resignFirstResponder];
            [self setupAppearance];
            [SPNotification showSuccessNotificationWithMessage:@"Message Sent" inViewController:self];
        }
    }];
}

- (void)sendFeedback {
    [[SPUser currentUser] postFeedbackInBackground:_messageTextView.text block:^(BOOL success, NSString *serverMessage) {
        [self notSendingState];
        if (!success) {
            [SPNotification showErrorNotificationWithMessage:serverMessage inViewController:self];
        } else {
            [_messageTextView resignFirstResponder];
            [self setupAppearance];
            [SPNotification showSuccessNotificationWithMessage:@"Feedback Sent" inViewController:self];
        }
    }];
}

- (void)sendingState {
    [_sendButton setEnabled:NO];
    [_sendActivityIndicator setHidden:NO];
    [_sendActivityIndicator startAnimating];
}

- (void)notSendingState {
    [_sendButton setEnabled:YES];
    [_sendActivityIndicator setHidden:YES];
    [_sendActivityIndicator startAnimating];
}

- (IBAction)onBackPress:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Crazy Keyboard Hiding Logic

-(void)keyboardWillShow:(NSNotification*)notification
{
    // Adjust the send button based on the keyboard height.
    NSDictionary *info = [notification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    CGFloat deltaHeight = kbSize.height - _currentKeyboardHeight;
    
    _sendButtonBottomConstraint.constant = _currentKeyboardHeight + deltaHeight + 8;
    _messageTopConstraint.constant = 80;
    
    _currentKeyboardHeight = kbSize.height;
    
    [UIView animateWithDuration:0.5
                     animations:^{
                         [self.view layoutIfNeeded]; // Called on parent view
                     }];
    
    [_sendButton setHidden:NO];
}

-(void)keyboardWillHide:(NSNotification*)notification {
    [_sendButton setHidden:YES];
    
    NSDictionary *info = [notification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    CGFloat deltaHeight = kbSize.height - _currentKeyboardHeight;
    
    _sendButtonBottomConstraint.constant = _currentKeyboardHeight + deltaHeight + 8;
    _messageTopConstraint.constant = [self messageTopConstraintForCenter];
    
    _currentKeyboardHeight = kbSize.height;
    
    [self.view layoutIfNeeded];
}

- (CGFloat) messageTopConstraintForCenter {
    CGFloat screenHeight = [[UIScreen mainScreen] bounds].size.height;
    return (screenHeight/2) - 45;
}

#pragma mark - UITextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:_placeHolderText]) {
        textView.text = @"";
        textView.textColor = [SPAppearance mainTextFieldColour];
    }
    [_sendButton setHidden:NO];
    [textView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@""]) {
        textView.text = _placeHolderText;
        textView.textColor = [SPAppearance seeThroughColour];
    }
    [textView resignFirstResponder];
}

#pragma mark - SPContainterViewDelegate

- (void) newVisableViewController:(UIViewController *)viewController {
    if (viewController == self) {
        NSLog(@"ComposeView is visable!!");
    } else {
        [self keyboardWillHide:nil];
    }
}

@end
