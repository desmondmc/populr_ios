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
@property (strong, nonatomic) IBOutlet UILabel *followLabel;
@property (strong, nonatomic) IBOutlet UIImageView *tickImage;
@property (strong, nonatomic) IBOutlet UIButton *followButton;

- (void)setupWithUser:(SPUser *)user;

@end
