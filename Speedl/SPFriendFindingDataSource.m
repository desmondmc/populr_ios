//
//  SPFriendFindingDataSource.m
//  Populr
//
//  Created by Desmond McNamee on 2015-09-28.
//  Copyright © 2015 Speedl. All rights reserved.
//

#import "SPFriendFindingDataSource.h"
#import "APAddressBook.h"
#import "SPPhoneValidation.h"
#import "APContact.h"

@interface SPFriendFindingDataSource ()

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) APAddressBook *addressBook;
@property (strong, nonatomic) NSArray *users;

@end

@implementation SPFriendFindingDataSource

- (id)initWithTableView:(UITableView *)tableView {
    self = [super init];
    if (self) {
        _tableView = tableView;
    }
    return self;
}

- (void)getContacts:(void (^)(NSInteger contactCount))block
          predicate:(NSString *)predicate {
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
                 if (serverMessage == nil) {
                     if (predicate) {
                         NSPredicate *thePredicate = [NSPredicate predicateWithFormat:predicate];
                         _users = [contacts filteredArrayUsingPredicate:thePredicate];
                     } else {
                         _users = contacts;
                     }
                     
                     [self.tableView reloadData];
                 }
                 
                 if (block) {
                     block(_users.count);
                 }
             }];
         }
         else
         {
             if (block) {
                 block(0);
             }
         }
     }];
}

- (APAddressBook *)addressBook {
    if (!_addressBook) {
        _addressBook = [[APAddressBook alloc] init];
    }
    return _addressBook;
}

#pragma mark - UITableView

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
    
    [cell setupWithUser:_users[indexPath.row]];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_users count];
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kCellFriendsCellHeight;
}

@end
