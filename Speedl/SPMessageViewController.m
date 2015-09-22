//
//  SPMessageViewController.m
//  Speedle
//
//  Created by Desmond McNamee on 2015-03-15.
//  Copyright (c) 2015 Desmond McNamee. All rights reserved.
//

#import "SPMessageViewController.h"
#import "SPComposeViewController.h"
#import "SPMessageLabel.h"

@interface SPMessageViewController ()

@property (strong, nonatomic) IBOutlet SPMessageLabel *messageLabel;
@property (strong, nonatomic) IBOutlet SPMessageLabel *countDown;
@property (strong, nonatomic) IBOutlet UIButton *restartButton;
@property (strong, nonatomic) IBOutlet UIButton *playButton;
@property (strong, nonatomic) IBOutlet UILabel *messageFromLabel;
@property (strong, nonatomic) IBOutlet UILabel *fromLabel;
@property (nonatomic) BOOL showCountDown;
@property (strong, nonatomic) SPMessage *message;

@end

@implementation SPMessageViewController

- (id)initWithMessage:(SPMessage *)message
        showCountDown:(BOOL)showCountDown {
    self = [super init];
    if (self) {
        _message = message;
        _showCountDown = showCountDown;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupAppearence];
    
    if (_message.message) {
        _messageLabel.messageText = _message.message;
    } else {
        _messageLabel.messageText = @"Error loading this message. Sorry.";
    }
    
    if ([_message.type isEqualToString:@"direct"]) {
        _messageFromLabel.text = @"PRIVATE MESSAGE FROM:";
    }
    
    if (_message.fromUsername) {
        _fromLabel.text = _message.fromUsername;
    } else {
        _fromLabel.text = @"Unknown User";
    }
    
    _messageLabel.wordPerMin = 250;
    
    if (_showCountDown) {
        _countDown.messageText = @"3 2 1";
    } else {
        _countDown.messageText = @"";
    }
    
    _countDown.wordPerMin = 60;
    
    if (_showCountDown) {
        [_countDown playAnimationWithCompletionBlock:^{
            [_messageLabel setHidden:NO];
            [_messageLabel playAnimationWithCompletionBlock:^{
                [self handleMessageComplete];
            }];
            [_countDown setHidden:YES];
            [_messageFromLabel setHidden:YES];
            [_fromLabel setHidden:YES];
        }];
    } else {
        [_messageLabel setHidden:NO];
        [_messageLabel playAnimationWithCompletionBlock:^{
            [self handleMessageComplete];
        }];
        [_countDown setHidden:YES];
        [_messageFromLabel setHidden:YES];
        [_fromLabel setHidden:YES];
    }
}

- (void)setupAppearence {
    self.view.backgroundColor = [SPAppearance globalBackgroundColour];
    
    [_restartButton setHidden:YES];
    [_playButton setHidden:YES];
    [_messageLabel setTextColor:[SPAppearance globalBackgroundColour]];
    [_countDown setTextColor:[SPAppearance globalBackgroundColour]];
    [_messageFromLabel setTextColor:[SPAppearance globalBackgroundColourWithAlpha:0.50]];
    _messageFromLabel.font = [SPAppearance mainSegmentControlFont];
    [_fromLabel setTextColor:[SPAppearance globalBackgroundColour]];
    
    [_messageLabel setHidden:YES];
}

- (IBAction)onPlayPress:(id)sender {
    [_restartButton setHidden:YES];
    [_playButton setHidden:YES];
    [_messageLabel playAnimationWithCompletionBlock:^{
        [self handleMessageComplete];
    }];
}

- (IBAction)onDismissPress:(id)sender {
    [self handleMessageComplete];
}

- (IBAction)onPausePress:(id)sender {
    [self runPauseActions];
}

- (IBAction)onRestartPress:(id)sender {
    [_messageLabel restartAnimation];
}

- (void) handleMessageComplete {
    [self dismissViewControllerAnimated:NO completion:nil];
    [_messageLabel setHidden:YES];

}

- (void) runPauseActions {
    [_restartButton setHidden:NO];
    [_playButton setHidden:NO];
    [_messageLabel pauseAnination];
}

- (IBAction)onGoRightPress:(id)sender {
    [self.containerViewController goToComposeViewControllerFromLeft];
}

#pragma mark - SPContainterViewDelegate

- (void) newVisableViewController:(UIViewController *)viewController {
    if (viewController == self) {
        NSLog(@"MessageView is visable!!");
    }
}
@end
