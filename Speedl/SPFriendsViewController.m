//
//  SPFriendsViewController.m
//  Speedl
//
//  Created by Desmond McNamee on 2015-04-08.
//  Copyright (c) 2015 Speedl. All rights reserved.
//

#import "SPFriendsViewController.h"

@interface SPFriendsViewController ()

@end

@implementation SPFriendsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)onGoLeftPress:(id)sender {
    [self.containerViewController goToComposeViewControllerFromRight];
}

#pragma mark - SPContainterViewDelegate

- (void) newVisableViewController:(UIViewController *)viewController {
    if (viewController == self) {
        NSLog(@"FriendsView is visable!!");
    }
}

@end
