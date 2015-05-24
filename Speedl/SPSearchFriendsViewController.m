//
//  SPSearchFriendsViewController.m
//  Speedl
//
//  Created by Desmond McNamee on 2015-05-15.
//  Copyright (c) 2015 Speedl. All rights reserved.
//

#import "SPSearchFriendsViewController.h"
#import "SPUsersTableDelegate.h"
#import "SPUsersTableDataSource.h"

@interface SPSearchFriendsViewController ()

@property (strong, nonatomic) IBOutlet UITextField *searchTextField;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) SPUsersTableDataSource *dataSource;
@property (strong, nonatomic) SPUsersTableDelegate *delegate;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation SPSearchFriendsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = [self delegate];
    self.tableView.dataSource = [self dataSource];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"SPFriendTableViewCell" bundle:nil] forCellReuseIdentifier:kFriendCellReuse];
    
    [self setupAppearance];
}

- (void) setupAppearance {
    [self.tableView styleAsMainSpeedlTableView];
    [self.searchTextField styleAsMainSpeedlTextField];
}

- (void) startSearch {
    
    if ([_searchTextField.text length] > 0) {
        [_tableView setHidden:YES];
        [_activityIndicator setHidden:NO];
        [SPUser searchForUserInBackgroundWithString:_searchTextField.text block:^(NSArray *users, NSString *serverMessage) {
            [_tableView setHidden:NO];
            [_activityIndicator setHidden:YES];
            self.dataSource.users = users;
            [self.tableView reloadData];
        }];
    }
}

-(SPUsersTableDataSource *)dataSource {
    if (!_dataSource) {
        _dataSource = [[SPUsersTableDataSource alloc] init];
    }
    return _dataSource;
}

-(SPUsersTableDelegate *)delegate {
    if (!_delegate) {
        _delegate = [[SPUsersTableDelegate alloc] init];
    }
    return _delegate;
}

#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.searchTextField resignFirstResponder];
    [self startSearch];
    
    return YES;
}

@end
