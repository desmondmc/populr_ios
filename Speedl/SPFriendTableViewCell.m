//
//  SPFriendTableViewCell.m
//  Speedl
//
//  Created by Desmond McNamee on 2015-04-19.
//  Copyright (c) 2015 Speedl. All rights reserved.
//

@implementation SPFriendTableViewCell

- (void)awakeFromNib {
    // Initialization code
    [self setBackgroundColor:[UIColor clearColor]];
    [self setupAppearance];
}

- (void) setupAppearance {
    [self.friendNameLabel styleAsFriendLabel];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setupWithUser:(SPUser *)user {
    _friendNameLabel.text = user.username;
    if ([user.following boolValue] == YES) {
        [self.followLabel styleAsFollowingLabel];
        _followLabel.text = @"Following";
    } else {
        [self.followLabel styleAsFollowLabel];
        _followLabel.text = @"Follow";
    }
}

@end
