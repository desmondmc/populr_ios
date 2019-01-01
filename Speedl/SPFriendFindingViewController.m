//
//  SPFriendFindingViewController.m
//  Populr
//
//  Created by Desmond McNamee on 2015-09-23.
//  Copyright © 2015 Speedl. All rights reserved.
//

#import "SPFriendFindingViewController.h"
#import "SPPhoneValidation.h"
#import "SPFriendFindingDataSource.h"
#import "MessageThrottle.h"

@interface SPFriendFindingViewController ()

@property (strong, nonatomic) SPFriendFindingDataSource *friendFindingDataSource;

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) IBOutlet UILabel *noResultsLabel;

@end

@implementation SPFriendFindingViewController

#pragma mark Local Accessors

- (SPFriendFindingDataSource *)friendFindingDataSource {
    if (!_friendFindingDataSource) {
        _friendFindingDataSource = [[SPFriendFindingDataSource alloc] initWithTableView:_tableView];
    }
    return _friendFindingDataSource;
}

#pragma mark Setup

- (void)setupAppearance {
    [self.view setBackgroundColor:[SPAppearance getMainBackgroundColour]];
}

- (void)setupTableView {
    
    [self.tableView registerNib:[SPFriendTableViewCell nib]
         forCellReuseIdentifier:[SPFriendTableViewCell reuseIdentifier]];
    self.tableView.dataSource = [self friendFindingDataSource];
    self.tableView.delegate = [self friendFindingDataSource];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.backgroundColor = [UIColor clearColor];
}

#pragma mark IBActions

- (IBAction)onBackPress:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark Life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController.interactivePopGestureRecognizer setDelegate:nil];
    [self setupAppearance];
    [self setupTableView];
    
    
    MTRule *rule = [self mt_limitSelector:@selector(loadContacts) oncePerDuration:30.0];
    rule.mode = MTPerformModeFirstly;
    [rule apply];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadContacts];
}

- (void)loadingState {
    [self.activityIndicator setHidden:NO];
    [self.activityIndicator startAnimating];
    [self.noResultsLabel setHidden:YES];
}

- (void)noResultsState {
    [self.activityIndicator setHidden:YES];
    [self.noResultsLabel setHidden:NO];
}

- (void)resultsState {
    [self.activityIndicator setHidden:YES];
    [self.noResultsLabel setHidden:YES];
}

- (void)loadContacts {
    [self loadingState];
    [[self friendFindingDataSource] getContacts:^(NSInteger contactCount) {
        if (contactCount == 0) {
            [self noResultsState];
        } else {
            [self resultsState];
        }
    } predicate:nil];
}

@end
