//
//  SPFriendFindingViewController.m
//  Populr
//
//  Created by Desmond McNamee on 2015-09-23.
//  Copyright © 2015 Speedl. All rights reserved.
//

#import "SPFriendFindingViewController.h"
#import "SPPhoneValidation.h"
#import "APAddressBook.h"
#import "APContact.h"
#import "SPFriendFindingDataSource.h"
#import "RateLimit.h"

@interface SPFriendFindingViewController ()

@property (strong, nonatomic) APAddressBook *addressBook;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) SPFriendFindingDataSource *friendFindingDataSource;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) IBOutlet UILabel *noResultsLabel;

@end

@implementation SPFriendFindingViewController

- (APAddressBook *)addressBook {
    if (!_addressBook) {
        _addressBook = [[APAddressBook alloc] init];
    }
    return _addressBook;
}

- (void)setupAppearance {
    [[self view] setBackgroundColor:[SPAppearance getMainBackgroundColour]];
}

- (void)setupTableView {
    [self.tableView registerNib:[UINib nibWithNibName:@"SPFriendTableViewCell" bundle:nil] forCellReuseIdentifier:kFriendCellReuse];
    self.tableView.dataSource = [self friendFindingDataSource];
    self.tableView.delegate = [self friendFindingDataSource];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.backgroundColor = [UIColor clearColor];
}

- (SPFriendFindingDataSource *)friendFindingDataSource {
    if (!_friendFindingDataSource) {
        _friendFindingDataSource = [[SPFriendFindingDataSource alloc] initWithTableView:_tableView];
    }
    return _friendFindingDataSource;
}

#pragma mark Buttons

- (IBAction)onBackPress:(id)sender {
    [[self navigationController] popViewControllerAnimated:YES];
}

#pragma mark Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController.interactivePopGestureRecognizer setDelegate:nil];
    [self setupAppearance];
    [self setupTableView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [RateLimit executeBlock:^{
        [self loadingState];
        [[self friendFindingDataSource] getContacts:^(NSInteger contactCount) {
            if (contactCount == 0) {
                [self noResultsState];
            } else {
                [self resultsState];
            }
        } predicate:nil];
    } name:@"FriendFinding" limit:30.0];
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

@end
