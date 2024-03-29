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
@property (strong, nonatomic) IBOutlet UILabel *friendsCountLabel;

@end

@implementation SPFriendsTableViewController


- (void)setupTableView {
    NSInteger count = [SPUser getFriendsArray].count;
    
    [self setFriendsLabelWithCount:count];
    
    [self.friendsCountLabel styleAsFriendCount];
    
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

- (void)setFriendsLabelWithCount:(NSInteger)count {
    if (count == 0) {
        self.friendsCountLabel.text = @"No friends";
        return;
    }
    NSString *friendString = @"friends";
    
    if (count == 1) {
        friendString = @"friend";
    }
    
    self.friendsCountLabel.text = [NSString stringWithFormat:@"%ld %@", (long)count, friendString];
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
        case SPFriendListTypeFriends:
            [self setupStartSearch];
            [self loadFriends];
            break;
        default:
            break;
    }
}

- (void)loadFriends {
    [[SPUser currentUser] getFriendsInBackground:^(NSArray *friends, NSString *serverMessage) {
        [self.refreshControl endRefreshing];
        
        if (serverMessage) {
            [SPNotification showErrorNotificationWithMessage:serverMessage inViewController:nil];
        }
        
        NSArray *savedFriends = [SPUser getFriendsArray];
        if (savedFriends > 0) {
            [self dataSource].users = [SPUser getFriendsArray];
            [self setupViewWithResults];
        } else {
            [self setupWithNoResults];
        }
    }];
}

- (void)setupStartSearch {
    if ([self dataSource].users.count == 0) {
        [self.tableView setHidden:YES];
        [self.activityIndicator setHidden:NO];
    }
}

- (void)setupViewWithResults {
    [self.tableView setHidden:NO];
    [self.activityIndicator setHidden:YES];
    [self.tableView reloadData];
}

- (void)setupWithNoResults {
    [self.activityIndicator setHidden:YES];
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

- (void)gotFriendsCount:(NSNotification *)notification {
    NSNumber *numberOfFollowing = [notification object];
    _friendsCountLabel.text = [numberOfFollowing stringValue];
    
    NSString *friendsString = @"friends";
    
    if ([_friendsCountLabel.text isEqualToString:@"1"]) {
        friendsString = @"friend";
    }
    
    self.friendsCountLabel.text = [NSString stringWithFormat:@"%@ %@", [numberOfFollowing stringValue], friendsString];
    
    if ([[numberOfFollowing stringValue] isEqualToString:@"0"]) {
        self.friendsCountLabel.text = @"No friends";
    }
    
    self.dataSource.users = [SPUser getFriendsArray];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self.tableView registerNib:[UINib nibWithNibName:@"SPFriendTableViewCell" bundle:nil] forCellReuseIdentifier:kFriendCellReuse];
    
    [self setupTableView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(gotFriendsCount:)
                                                 name:kSPFriendsCountNotification
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [self refreshTable];
}


@end
