//
//  SPSearchFriendsViewController.m
//  Speedl
//
//  Created by Desmond McNamee on 2015-05-15.
//  Copyright (c) 2015 Speedl. All rights reserved.
//

#import "SPSearchFriendsViewController.h"

@interface SPSearchFriendsViewController ()

@property (strong, nonatomic) IBOutlet UITextField *searchTextField;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation SPSearchFriendsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupAppearance];
}

- (void) setupAppearance {
    [self.searchTextField styleAsMainSpeedlTextField];
    
    self.searchTextField.textColor = [SPAppearance seeThroughColour];
}

@end
