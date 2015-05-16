//
//  SPUsersTableDataSource.m
//  Speedl
//
//  Created by Desmond McNamee on 2015-05-15.
//  Copyright (c) 2015 Speedl. All rights reserved.
//

#import "SPUsersTableDataSource.h"

@interface SPUsersTableDataSource ()

@end

@implementation SPUsersTableDataSource

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
    
    [cell setupWithUser:_users[indexPath.row]];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_users count];
}

@end
