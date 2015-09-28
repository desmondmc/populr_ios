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

- (void)getContacts {
    NSString *countryCode = [SPPhoneValidation getUserCountryCodeNeverNil];
    
    // Loading contacts
    NSMutableArray *contactsArray = [NSMutableArray new];
    
    [[self addressBook] loadContacts:^(NSArray *contacts, NSError *error)
    {
        if (!error)
        {
            for (APContact *contact in contacts) {
                if (!contact.phones || contact.phones.count == 0) {
                    continue;
                }
                
                NSMutableDictionary *newContact = [NSMutableDictionary new];
                
                if (contact.firstName) {
                    [newContact setObject:contact.firstName forKey:@"first_name"];
                }
                
                if (contact.lastName) {
                    [newContact setObject:contact.lastName forKey:@"last_name"];
                }
                
                NSMutableArray *newPhones = [NSMutableArray new];
                for (NSString *phone in contact.phones) {
                    NSString *interNumber = [SPPhoneValidation getInternationalNumberFromPhoneNumber:phone
                                                                 countryCode:countryCode];
                    [newPhones addObject:interNumber];
                    
                }
                [newContact setObject:newPhones forKey:@"phones"];
                
                [contactsArray addObject:newContact];
            }
            
            [[SPUser currentUser] postContactDataInBackground:contactsArray block:^(NSArray *contacts, NSString *serverMessage) {
                if (serverMessage != nil) {
                    [SPNotification showErrorNotificationWithMessage:@"Error loading contacts" inViewController:self];
                } else {
                    [self friendFindingDataSource].users = contacts;
                    [self.tableView reloadData];
                }
                if (contacts.count) {
                    [self resultsState];
                } else {
                    [self noResultsState];
                }
            }];
        }
        else
        {
            [SPNotification showErrorNotificationWithMessage:@"Error loading contacts" inViewController:self];
        }
    }];
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
        _friendFindingDataSource = [SPFriendFindingDataSource new];
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
    [self setupAppearance];
    [self setupTableView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [RateLimit executeBlock:^{
        [self loadingState];
        [self getContacts];
    } name:@"GetContacts" limit:30.0];
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
