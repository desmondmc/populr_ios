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

@interface SPFriendFindingViewController ()

@property (strong, nonatomic) APAddressBook *addressBook;

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
                    NSLog(@"$$$$$$$$$$$$$$$$$$Contacts Array: \n%@", contacts);
                }
                
            }];
        }
        else
        {
            [SPNotification showErrorNotificationWithMessage:@"Error loading contacts" inViewController:self];
        }
    }];
}


#pragma mark Buttons

- (IBAction)onBackPress:(id)sender {
    [[self navigationController] popViewControllerAnimated:YES];
}

- (IBAction)onButtonPress:(id)sender {
    [self getContacts];
}


#pragma mark Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupAppearance];
}


@end
