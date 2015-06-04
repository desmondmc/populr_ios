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

#define kSearchFieldDefaultYConstraintValue 8;

@interface SPSearchFriendsViewController ()

@property (strong, nonatomic) IBOutlet UITextField *searchTextField;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) SPUsersTableDataSource *dataSource;
@property (strong, nonatomic) SPUsersTableDelegate *delegate;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) IBOutlet UILabel *noResultsLabel;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *searchTextFieldUpperConstraint;

@end

@implementation SPSearchFriendsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = [self delegate];
    self.tableView.dataSource = [self dataSource];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"SPFriendTableViewCell" bundle:nil] forCellReuseIdentifier:kFriendCellReuse];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [self setupAppearance];
}

- (void) setupAppearance {
    [self.tableView styleAsMainSpeedlTableView];
    [self.searchTextField styleAsMainSpeedlTextField];
    
    [self setupForPresearch];
}

- (void)setupForPresearch {
    [_tableView setHidden:YES];
    [_noResultsLabel setHidden:YES];
    //[self centerSearchTextField];
}

- (void)setupForMidSearch {
    [_tableView setHidden:YES];
    [_noResultsLabel setHidden:YES];
    [_activityIndicator setHidden:NO];
}

- (void)setupForPostSearchWithResults {
    [_tableView setHidden:NO];
    [_noResultsLabel setHidden:YES];
}

- (void)setupForPostSearchNoResults {
    [_tableView setHidden:YES];
    [_noResultsLabel setHidden:NO];
}

-(void)keyboardWillShow:(NSNotification*)notification {
    [self moveSearchTextFieldToTop];
}

- (void)startSearch {
    
    if ([_searchTextField.text length] > 0) {
        NSString *lowercaseSearch = [_searchTextField.text lowercaseString];
        [self setupForMidSearch];
        [SPUser searchForUserInBackgroundWithString:lowercaseSearch block:^(NSArray *users, NSString *serverMessage) {
            [_activityIndicator setHidden:YES];
            if (users.count > 0) {
                [self setupForPostSearchWithResults];
                [self dataSource].users = users;
                [self.tableView reloadData];
            } else {
                [self setupForPostSearchNoResults];
            }

        }];
    }
}

- (void)centerSearchTextField {
    
    [UIView animateWithDuration:0.5
                     animations:^{
                         [self.view layoutIfNeeded]; // Called on parent view
                     }];
}

- (void)moveSearchTextFieldToTop {
    _searchTextFieldUpperConstraint.constant = kSearchFieldDefaultYConstraintValue;
    
    [UIView animateWithDuration:0.5
                     animations:^{
                         [self.view layoutIfNeeded]; // Called on parent view
                     }];
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
