//
//  SPFollowersTableViewController.m
//  Speedl
//
//  Created by Desmond McNamee on 2015-05-14.
//  Copyright (c) 2015 Speedl. All rights reserved.
//

#import "SPFriendsTableViewController.h"
#import "SPFriendTableViewCell.h"
#import "SVPullToRefresh.h"


@interface SPFriendsTableViewController ()

@property (strong, nonatomic) NSArray *usersArray;

@end

@implementation SPFriendsTableViewController


- (void)setupTableView {
    self.tableView.backgroundColor = [UIColor clearColor];
    [self.tableView setSeparatorColor:[SPAppearance seeThroughColour]];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    __weak SPFriendsTableViewController *wSelf = self;
    [self.tableView addPullToRefreshWithActionHandler:^{
        [wSelf refreshTable];
        [wSelf.tableView.pullToRefreshView stopAnimating];
    }];
    
    [self.tableView.pullToRefreshView setArrowColor:[UIColor whiteColor]];
    [self.tableView.pullToRefreshView setTextColor:[UIColor whiteColor]];
    
    [self refreshTable];
}

- (void) refreshTable {
    switch (_listType) {
        case SPFriendListTypeFollowers:
            [self loadFollowers];
            break;
        case SPFriendListTypeFollowing:
            //
            break;
        default:
            break;
    }
}

- (void)loadFollowers {
    [[SPUser currentUser] getFollowersInBackground:^(NSArray *followers, NSString *serverMessage) {
        _usersArray = followers;
        [self.tableView reloadData];
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

#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self.tableView registerNib:[UINib nibWithNibName:@"SPFriendTableViewCell" bundle:nil] forCellReuseIdentifier:kFriendCellReuse];
    
    [self setupTableView];
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SPFriendTableViewCell *cell = (SPFriendTableViewCell *)
    [tableView dequeueReusableCellWithIdentifier:kFriendCellReuse forIndexPath:indexPath];
    
    if (cell == nil) {
        //There was no reusablecell to dequeue
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"SPFriendTableViewCell"
                                                     owner:self
                                                   options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    [cell setupWithUser:_usersArray[indexPath.row]];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_usersArray count];
}



@end
