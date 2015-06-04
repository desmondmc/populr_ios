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
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) IBOutlet UILabel *upperNoResultsLabel;
@property (strong, nonatomic) IBOutlet UILabel *lowerNoResultsLabel;
@property (strong, nonatomic) IBOutlet UIView *noResultsView;

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
    [self.tableView addSubview:self.refreshControl];
    
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
            _upperNoResultsLabel.text = @"YOU HAVE NO FOLLOWERS";
            _lowerNoResultsLabel.text = @"TELL YOUR FRIENDS ABOUT GZELLE!";
            [self setupStartSearch];
            [self loadFollowers];
            break;
        case SPFriendListTypeFollowing:
            _upperNoResultsLabel.text = @"YOU ARE FOLLOWING NO ONE";
            _lowerNoResultsLabel.text = @"SEARCH USERNAMES";
            [self setupStartSearch];
            [self loadFollowing];
            break;
        default:
            break;
    }
}

- (void)loadFollowers {
    [[SPUser currentUser] getFollowersInBackground:^(NSArray *followers, NSString *serverMessage) {
        [self.refreshControl endRefreshing];
        if (followers.count > 0) {
            [self dataSource].users = followers;
            [self setupViewWithResults];
        } else {
            [self setupWithNoResults];
        }
    }];
}

- (void)loadFollowing {
    [[SPUser currentUser] getFollowingInBackground:^(NSArray *following, NSString *serverMessage) {
        [self.refreshControl endRefreshing];
        if (following.count > 0) {
            [self dataSource].users = following;
            [self setupViewWithResults];
        } else {
            [self setupWithNoResults];
        }

    }];
}

- (void)setupStartSearch {
    if ([self dataSource].users.count == 0) {
        [self.noResultsView setHidden:YES];
        [self.tableView setHidden:YES];
        [self.activityIndicator setHidden:NO];
    }
}

- (void)setupViewWithResults {
    [self.noResultsView setHidden:YES];
    [self.tableView setHidden:NO];
    [self.activityIndicator setHidden:YES];
    [self.tableView reloadData];
}

- (void)setupWithNoResults {
    [self.activityIndicator setHidden:YES];
    [self.noResultsView setHidden:NO];
    [self.tableView setHidden:NO];
    [self.tableView reloadData];
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
