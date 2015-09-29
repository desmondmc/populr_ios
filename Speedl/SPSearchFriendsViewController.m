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
#import "SPFriendFindingDataSource.h"
#import "RateLimit.h"

#define kSearchFieldDefaultYConstraintValue 8;

@interface SPSearchFriendsViewController ()

@property (strong, nonatomic) IBOutlet UITextField *searchTextField;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) SPUsersTableDataSource *dataSource;
@property (strong, nonatomic) SPUsersTableDelegate *delegate;
@property (strong, nonatomic) SPFriendFindingDataSource *friendFindingDataSource;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) IBOutlet UILabel *noResultsLabel;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *searchTextFieldUpperConstraint;
@property (nonatomic) CGFloat currentKeyboardHeight;
@property (strong, nonatomic) IBOutlet UITableView *suggestionsTableView;
@property (strong, nonatomic) IBOutlet UIView *suggestionsView;

@end

@implementation SPSearchFriendsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = [self delegate];
    self.tableView.dataSource = [self dataSource];
    self.suggestionsTableView.delegate = [self friendFindingDataSource];
    self.suggestionsTableView.dataSource = [self friendFindingDataSource];
    
    [self.suggestionsTableView registerNib:[UINib nibWithNibName:@"SPFriendTableViewCell" bundle:nil] forCellReuseIdentifier:kFriendCellReuse];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"SPFriendTableViewCell" bundle:nil] forCellReuseIdentifier:kFriendCellReuse];
    
    [self setupAppearance];
}

- (void)viewDidAppear:(BOOL)animated {
    [RateLimit executeBlock:^{
        [[self friendFindingDataSource] getContacts:^(NSInteger contactCount) {
            if (contactCount > 0) {
                [self setupForPostSuggestions];
            }
        } predicate:@"isFriend == NO"];
    } name:@"SearchFriends" limit:30.0];
    
    // Listen for keyboard appearances and disappearances
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)keyboardWillShow:(NSNotification*)notification
{
    if (/* DISABLES CODE */ (NO)) {
        // Adjust the send button based on the keyboard height.
        NSDictionary *info = [notification userInfo];
        CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
        
        _searchTextFieldUpperConstraint.constant = kSearchFieldDefaultYConstraintValue;
        
        _currentKeyboardHeight = kbSize.height;
        
        [UIView animateWithDuration:0.5
                         animations:^{
                             [self.view layoutIfNeeded]; // Called on parent view
                         }];
    }
}
-(void)keyboardWillHide:(NSNotification*)notification {
    if (/* DISABLES CODE */ (NO)) {
        if ([_tableView isHidden]) {
            NSDictionary *info = [notification userInfo];
            CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
            
            _searchTextFieldUpperConstraint.constant = [self messageTopConstraintForCenter];
            
            _currentKeyboardHeight = kbSize.height;
            
            [UIView animateWithDuration:0.5
                             animations:^{
                                 [self.view layoutIfNeeded]; // Called on parent view
                             }];
        }
    }
}

- (CGFloat) messageTopConstraintForCenter {
    CGFloat viewHeight = [self view].frame.size.height;
    
    return (viewHeight/2) - _searchTextField.frame.size.height - 53;
}

- (void) setupAppearance {
    [self.tableView styleAsMainSpeedlTableView];
    [self.suggestionsTableView styleAsMainSpeedlTableView];
    [self.searchTextField styleAsMainSpeedlTextField];
    
    [self setupForPresearch];
}

- (void)setupForPostSuggestions {
    [_suggestionsView setHidden:NO];
    [_tableView setHidden:YES];
    [_noResultsLabel setHidden:YES];
}

- (void)setupForPresearch {
    [_suggestionsView setHidden:YES];
    [_tableView setHidden:YES];
    [_noResultsLabel setHidden:YES];
}

- (void)setupForMidSearch {
    [_suggestionsView setHidden:YES];
    [_tableView setHidden:YES];
    [_noResultsLabel setHidden:YES];
    [_activityIndicator setHidden:NO];
}

- (void)setupForPostSearchWithResults {
    [_suggestionsView setHidden:YES];
    [_tableView setHidden:NO];
    [_noResultsLabel setHidden:YES];
}

- (void)setupForPostSearchNoResults {
    [_suggestionsView setHidden:NO];
    [_tableView setHidden:YES];
    [_noResultsLabel setHidden:NO];
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
            _searchTextField.text = @"";
        }];
    }
}

- (void)centerSearchTextField {
    
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

- (SPFriendFindingDataSource *)friendFindingDataSource {
    if (!_friendFindingDataSource) {
        _friendFindingDataSource = [[SPFriendFindingDataSource alloc] initWithTableView:_suggestionsTableView];
    }
    return _friendFindingDataSource;
}

#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.searchTextField resignFirstResponder];
    [self startSearch];
    
    return YES;
}

@end
