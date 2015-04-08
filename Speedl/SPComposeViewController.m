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
@property (strong, nonatomic) IBOutlet UITextField *messageTextField;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *textFieldTopConstraint;

@end

@implementation SPComposeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [_messageTextField becomeFirstResponder];
    
    // Listen for keyboard appearances and disappearances
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [_messageTextField becomeFirstResponder];
}
- (IBAction)onMicPress:(id)sender {
    [[SPUser currentUser] getMessagesInBackground:^(NSArray *messages, NSString *serverMessage) {
        for (SPMessage *message in messages) {
            NSLog(@"%@", message.body);
        }
    }];
}

-(void)keyboardDidShow:(NSNotification*)notification
{
    [self.view layoutIfNeeded];
    NSDictionary* keyboardInfo = [notification userInfo];
    NSValue* keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameBeginUserInfoKey];
    CGFloat keyboardHeight = [keyboardFrameBegin CGRectValue].size.height;
    
    _micButtonBottomConstraint.constant = keyboardHeight + 30;
    _sendButtonBottomConstraint.constant = keyboardHeight + 30;
    _textFieldTopConstraint.constant = (self.view.frame.size.height - keyboardHeight
                                        - (_messageTextField.frame.size.height/2)) / 2;
    
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

@end
