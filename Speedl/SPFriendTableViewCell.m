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
        _followLabel.font = [SPAppearance timeLabelFont];
        _followLabel.text = @"Following";
        _tickImage.image = [UIImage imageNamed:@"tick_"];
    } else {
        [self.followLabel styleAsFollowLabel];
        _followLabel.font = [SPAppearance timeLabelFont];
        _followLabel.text = @"Follow";
        _tickImage.image = [UIImage imageNamed:@"plus_"];
    }
}

@end
