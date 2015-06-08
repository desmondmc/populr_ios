//
//  SPCustomNotificationViewController.m
//  gzelle
//
//  Created by Desmond McNamee on 2015-06-08.
//  Copyright (c) 2015 Speedl. All rights reserved.
//

#import "SPCustomNotificationViewController.h"

@interface SPCustomNotificationViewController ()
@property (strong, nonatomic) IBOutlet UILabel *messageLabel;

@end

@implementation SPCustomNotificationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupAppearance];
}

- (void)setupAppearance {
    _messageLabel.font = [SPAppearance mainTextFieldFont];
    _messageLabel.textColor = [SPAppearance mainTextFieldColour];
}

- (void)presentInViewController:(UIViewController *)parentViewController
{
    [self willMoveToParentViewController:parentViewController];
    [_parentViewController.view addSubview:self.view];
    
}

@end
