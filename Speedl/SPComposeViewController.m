//
//  SPComposeViewController.m
//  Speedle
//
//  Created by Desmond McNamee on 2015-03-15.
//  Copyright (c) 2015 Desmond McNamee. All rights reserved.
//

#import "SPComposeViewController.h"
#import "SPMessageViewController.h"


#define kPlaceHolderText @"Write something..."

#define kPreviewImageOn [UIImage imageNamed:@"preview_button_active"]
#define kPreviewImageOff [UIImage imageNamed:@"preview_button_off"]

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
@property (strong, nonatomic) SPMessageProcessor *messageProcessor;

// Help Popup Properties
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *autocompleteHeightConstraint;
@property (strong, nonatomic) IBOutlet UIView *autocompleteView;
@property (strong, nonatomic) IBOutlet UIView *sendCircleView;
@property (strong, nonatomic) IBOutlet UILabel *sendLabel;
@property (strong, nonatomic) IBOutlet UILabel *helpLabel1;
@property (strong, nonatomic) IBOutlet UILabel *helpLabel2;
@property (strong, nonatomic) IBOutlet UIButton *previewButton;
@property (strong, nonatomic) IBOutlet UIView *noFriendsView;
@property (strong, nonatomic) IBOutlet UILabel *noFriendsLabel1;
@property (strong, nonatomic) IBOutlet UILabel *noFriendsLabel2;
@property (strong, nonatomic) IBOutlet UILabel *noFriendsSmallLabel;


@property (strong, nonatomic) NSString *atWord;
@property (nonatomic) BOOL captureText;

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
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(gotFriendsCount:)
                                                 name:kSPFriendsCountNotification
                                               object:nil];
    
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

- (void)gotFriendsCount:(NSNotification *)notification {
    [self checkFriendsState];
}

- (void) setupAppearance {
    self.view.backgroundColor = [SPAppearance getSecondColourForToday];
    [self notSendingState];
    [self.sendButton styleAsMainSpeedlButton];
    [self.messageTextView styleAsMainSpeedlTextView];
    self.sendLabel.textColor = [SPAppearance getMainBackgroundColour];
    [self.sendLabel styleAsSendLabel];
    [self.sendActivityIndicator setColor:[SPAppearance getMainBackgroundColour]];
    [self.helpLabel1 styleAsHelpLabel];
    [self.helpLabel2 styleAsHelpLabel];
    
    [self.noFriendsLabel1 styleNoFriendsLargeText];
    [self.noFriendsLabel2 styleNoFriendsLargeText];
    [self.noFriendsSmallLabel styleNoFriendsSmallText];
    [self.noFriendsView setBackgroundColor:[SPAppearance getMainBackgroundColour]];
    
    // Called to setup view for keyboard down state at the begining.
    [self keyboardWillHide:nil];
    
    if (_isFeedBackView) {
        [self setupForFeedback];
    } else {
        _placeHolderText = kPlaceHolderText;
        self.messageTextView.text = _placeHolderText;
    }
    [self enableButtons:NO];
    [self checkFriendsState];
}

- (void)checkFriendsState {
    BOOL hideNoFriendsView = YES;
    NSArray *friends = [SPUser getFriendsArray];
    if (friends.count == 0) {
        hideNoFriendsView = NO;
    }
    
    if (_isFeedBackView) {
        hideNoFriendsView = YES;
    }
    
    [_noFriendsView setHidden:hideNoFriendsView];
}

- (void)setupForFeedback {
    _backButton.hidden = NO;
    _backButtonImage.hidden = NO;
    _placeHolderText = @"What's your problem?";
    self.messageTextView.text = _placeHolderText;
    _helpLabel1.hidden = YES;
    _helpLabel2.hidden = YES;
    _previewButton.hidden = YES;
    _noFriendsView.hidden = YES;
    [self.navigationController.interactivePopGestureRecognizer setDelegate:nil];
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
- (IBAction)onPreviewPress:(id)sender {
    SPMessage *message = [SPMessage new];
    message.message = _messageTextView.text;
    
    SPMessageViewController *messageViewController = [[SPMessageViewController alloc] initWithMessage:message showCountDown:NO];
    
    [self presentViewController: messageViewController animated:NO completion:^{
        [self keyboardWillHide:nil];
    }];
}



- (NSString *)getNoMessageErrorString {
    if (_isFeedBackView) {
        return @"type something...";
    } else {
        return @"Type a message, kid.";
    }
}

- (void)sendMessage {
    NSArray *usersToSendTo = [[self messageProcessor] followerIDsInMessage];
    [[SPUser currentUser] postMessageInBackground:_messageTextView.text
                                            users:usersToSendTo
                                            block:^(BOOL success, NSString *serverMessage) {
        [self notSendingState];
        if (!success) {
            [SPNotification showErrorNotificationWithMessage:serverMessage inViewController:self];
        } else {
            _messageProcessor = nil;
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
            _messageTextView.text = @"";
            [SPNotification showSuccessNotificationWithMessage:@"Thanks!" inViewController:self.navigationController];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];
}

- (void)sendingState {
    [_sendLabel setHidden:YES];
    [_sendButton setEnabled:NO];
    [_sendActivityIndicator setHidden:NO];
    [_sendActivityIndicator startAnimating];
}

- (void)notSendingState {
    [_sendLabel setHidden:NO];
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
    if (![self.messageTextView isFirstResponder]) {
        return;
    }
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
    
    [self hideHelpLabels:YES];
}

-(void)keyboardWillHide:(NSNotification*)notification {
    CGFloat height = 0;
    
    if (notification) {
        NSDictionary *info = [notification userInfo];
        CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
        height = kbSize.height;
    }
    
    if (![self.messageTextView isFirstResponder]) {
        _currentKeyboardHeight = 0;
        height = 0;
    }
    
    [self hideHelpLabels:NO];
    
    CGFloat deltaHeight = height - _currentKeyboardHeight;
    
    _sendButtonBottomConstraint.constant = _currentKeyboardHeight + deltaHeight + 8;
    _messageTopConstraint.constant = [self messageTopConstraintForCenter];
    
    _currentKeyboardHeight = height;
    
    [self.view layoutIfNeeded];
}

- (void)hideHelpLabels:(BOOL)hide {
    if (![_messageTextView.text isEqualToString:kPlaceHolderText]) {
        hide = YES;
    }
    [_helpLabel1 setHidden:hide];
    [_helpLabel2 setHidden:hide];
}

- (void)enableButtons:(BOOL)enableButtons {
    if (enableButtons) {
        [_sendCircleView setAlpha:1.0];
    } else {
        [_sendCircleView setAlpha:0.5];
    }
    
    [_previewButton setEnabled:enableButtons];
    [_sendButton setEnabled:enableButtons];
}

- (CGFloat) messageTopConstraintForCenter {
    CGFloat screenHeight = [[UIScreen mainScreen] bounds].size.height;
    return (screenHeight/2) - 45;
}

- (SPMessageProcessor *)messageProcessor {
    if (!_messageProcessor) {
        _messageProcessor = [SPMessageProcessor new];
        _messageProcessor.delegate = self;
    }
    return _messageProcessor;
}

#pragma mark - UITextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:_placeHolderText]) {
        textView.text = @"";
    }
    
    [textView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@""]) {
        textView.text = _placeHolderText;
    }
    
    [self hideHelpLabels:NO];
    [textView resignFirstResponder];
}

- (void)textViewDidChange:(UITextView *)textView {
    if ([textView.text isEqualToString:@""] ||
        [textView.text isEqualToString:_placeHolderText]) {
        
        [self enableButtons:NO];
    } else {
        [self enableButtons:YES];
    }
    
    if (_isFeedBackView) {
        return;
    }
    
    [[self messageProcessor] textViewDidChange:textView];
}

- (void)textViewDidChangeSelection:(UITextView *)textView {
    [[self messageProcessor] textViewDidChangeSelection:textView];
}

#pragma mark - SPContainterViewDelegate

- (void) newVisableViewController:(UIViewController *)viewController {
    if (viewController == self) {
        NSLog(@"ComposeView is visable!!");
        [self checkFriendsState];
    } else {
        // Fixes bug where view goes out of wack when the keyboard is up and the user changes screens
        [self keyboardWillHide:nil];
    }
}

#pragma mark - SPMessageProcessorDelegate

- (void)displayTableView:(UITableView *)tableView height:(CGFloat)height {
    [_autocompleteView addSubview:tableView];
    [tableView reloadData];
    [SPAutoLayout constrainSubviewToFillSuperview:tableView];
    [self showAutocompleteViewWithHeight:height];
}

- (void)hideTableView {
    [self hideAutocompleteView];
}

- (void)userSelectionMade:(NSString *)selection {
    [_messageTextView replaceRange:_messageTextView.selectedTextRange withText:selection];
}

#pragma mark - Helper Popup Methods

- (void)showAutocompleteViewWithHeight:(CGFloat)height {
    _autocompleteHeightConstraint.constant = height;
    [UIView animateWithDuration:0.2
                     animations:^{
                         [self.view layoutIfNeeded];
                     }];
}

- (void)hideAutocompleteView {
    _autocompleteHeightConstraint.constant = 0;
    [UIView animateWithDuration:0.2
                     animations:^{
                         [self.view layoutIfNeeded];
                     }];
}

@end
