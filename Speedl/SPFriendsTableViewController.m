//
//  SPFollowersTableViewController.m
//  Speedl
//
//  Created by Desmond McNamee on 2015-05-14.
//  Copyright (c) 2015 Speedl. All rights reserved.
//

#import "SPFriendsTableViewController.h"
#import "SPUsersTableDataSource.h"
#import "SPUsersTableDelegate.h"
#import "SVPullToRefresh.h"


@interface SPFriendsTableViewController ()

@property (strong, nonatomic) NSArray *usersArray;
@property (strong, nonatomic) SPUsersTableDataSource *dataSource;
@property (strong, nonatomic) SPUsersTableDelegate *delegate;

@end

@implementation SPFriendsTableViewController


- (void)setupTableView {
    [self.tableView styleAsMainSpeedlTableView];
    
    self.tableView.delegate = [self delegate];
    self.tableView.dataSource = [self dataSource];
    
    //Add pull to refresh
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = [UIColor clearColor];
    self.refreshControl.tintColor = [UIColor whiteColor];
    [self.refreshControl addTarget:self
                            action:@selector(refreshTable)
                  forControlEvents:UIControlEventValueChanged];
    
    [self refreshTable];
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

- (void) refreshTable {
    switch (_listType) {
        case SPFriendListTypeFollowers:
            [self loadFollowers];
            break;
        case SPFriendListTypeFollowing:
            [self loadFollowing];
            break;
        default:
            break;
    }
}

- (void)loadFollowers {
    [[SPUser currentUser] getFollowersInBackground:^(NSArray *followers, NSString *serverMessage) {
        [self dataSource].users = followers;
        [self.tableView reloadData];
        [self.refreshControl endRefreshing];
    }];
}

- (void)loadFollowing {
    [[SPUser currentUser] getFollowingInBackground:^(NSArray *following, NSString *serverMessage) {
        [self dataSource].users = following;
        [self.tableView reloadData];
        [self.refreshControl endRefreshing];
    }];
}

- (void)viewDidLayoutSubviews {
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self.tableView registerNib:[UINib nibWithNibName:@"SPFriendTableViewCell" bundle:nil] forCellReuseIdentifier:kFriendCellReuse];
    
    [self setupTableView];
}


@end
