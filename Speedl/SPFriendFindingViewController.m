//
//  SPFriendFindingViewController.m
//  Populr
//
//  Created by Desmond McNamee on 2015-09-23.
//  Copyright © 2015 Speedl. All rights reserved.
//

#import "SPFriendFindingViewController.h"

#import "APAddressBook.h"
#import "APContact.h"

@interface SPFriendFindingViewController ()

@end

@implementation SPFriendFindingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self getContacts];
}

- (void)getContacts {
    
    APAddressBook *addressBook = [[APAddressBook alloc] init];
    
    // Loading contacts
    
    [addressBook loadContacts:^(NSArray *contacts, NSError *error)
    {
        // hide activity
        
        if (!error)
        {
            for (APContact *contact in contacts) {
                NSLog(@"Full name: %@ %@", contact.firstName, contact.lastName);
                for (NSString *phoneNumber in contact.phones) {
                    NSLog(@" - Phone: %@", phoneNumber);
                }
            }
        }
        else
        {
            NSLog(@"Error getting contects: %@", error);
        }
    }];
}





@end
