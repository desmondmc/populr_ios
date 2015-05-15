//
//  SPFriendTableViewCell.h
//  Speedl
//
//  Created by Desmond McNamee on 2015-04-19.
//  Copyright (c) 2015 Speedl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SPFriendTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *friendNameLabel;
@property (strong, nonatomic) IBOutlet UIView *seporatorView;

- (void)setupWithUser:(SPUser *)user;

@end
