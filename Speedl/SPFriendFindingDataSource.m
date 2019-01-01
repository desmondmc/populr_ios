//
//  SPFriendFindingDataSource.m
//  Populr
//
//  Created by Desmond McNamee on 2015-09-28.
//  Copyright © 2015 Speedl. All rights reserved.
//

#import "SPFriendFindingDataSource.h"
#import "SPPhoneValidation.h"
#import <Contacts/Contacts.h>

@interface SPFriendFindingDataSource ()

@property (strong, nonatomic) UITableView *tableView;
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

// Sends users contacts to the backend to find friends who are already using populr.
- (void)getContacts:(void (^)(NSInteger contactCount))block
          predicate:(NSString *)predicate {
    NSString *countryCode = [SPPhoneValidation getUserCountryCodeNeverNil];
    
    // Loading contacts
    NSMutableArray *contactsArray = [NSMutableArray new];
    
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        CNContactStore *store = [CNContactStore new];
        
        [store containersMatchingPredicate:[CNContainer predicateForContainersWithIdentifiers: @[store.defaultContainerIdentifier]] error:nil];
        NSArray *keysToFetch =@[
                                CNContactPhoneNumbersKey,
                                CNContactFamilyNameKey,
                                CNContactGivenNameKey,
                                ];
        CNContactFetchRequest * request = [[CNContactFetchRequest alloc] initWithKeysToFetch:keysToFetch];
        
        NSError *requestError;
        [store enumerateContactsWithFetchRequest:request
                                           error:&requestError
                                      usingBlock:^(CNContact * __nonnull contact, BOOL * __nonnull stop) {
          if (requestError) {
              *stop = true;
              block(_users.count);
              return;
          }
          
          if (!contact.phoneNumbers || contact.phoneNumbers.count == 0) {
              return;
          }
          
          NSMutableDictionary *newContact = [NSMutableDictionary new];
          
          if (contact.givenName) {
              [newContact setObject:contact.givenName forKey:@"first_name"];
          }
          
          if (contact.familyName) {
              [newContact setObject:contact.familyName forKey:@"last_name"];
          }
          
          NSMutableArray *newPhones = [NSMutableArray new];
          for (CNLabeledValue<CNPhoneNumber*> *phone in contact.phoneNumbers) {
              NSString *interNumber = [SPPhoneValidation getInternationalNumberFromPhoneNumber:[[phone value] stringValue]
                                                                                   countryCode:countryCode];
              [newPhones addObject:interNumber];
              
          }
          [newContact setObject:newPhones forKey:@"phones"];
          [contactsArray addObject:newContact];
        }];
        
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
    });
}

- (void) loadContactsFromStore {
    
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
