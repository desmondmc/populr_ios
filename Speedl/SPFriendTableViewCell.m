//
//  SPFriendTableViewCell.m
//  Speedl
//
//  Created by Desmond McNamee on 2015-04-19.
//  Copyright (c) 2015 Speedl. All rights reserved.
//

@interface SPFriendTableViewCell ()

@property (strong, nonatomic) SPUser *user;

@end

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
- (IBAction)didTapFollow:(id)sender {
    [self loadingState];
    [[SPUser currentUser] followUserInBackground:_user block:^(BOOL success, NSString *serverMessage) {
        if (success) {
            [self followingState];
        } else {
            [self followState];
        }
    }];
}

- (void)setupWithUser:(SPUser *)user {
    _user = user;
    _friendNameLabel.text = user.username;
    if ([user.following boolValue] == YES) {
        [self followingState];
    } else {
        [self followState];
    }
}

- (void)followingState {
    [_activityIndicator setHidden:YES];
    [self.followLabel styleAsFollowingLabel];
    _followLabel.font = [SPAppearance timeLabelFont];
    _followLabel.text = @"Following";
    [_tickImage setHidden:NO];
    _tickImage.image = [UIImage imageNamed:@"tick_trans_"];
    _followButton.enabled = NO;
}

- (void)followState {
    [_activityIndicator setHidden:YES];
    [self.followLabel styleAsFollowLabel];
    _followLabel.font = [SPAppearance timeLabelFont];
    _followLabel.text = @"Follow";
    [_tickImage setHidden:NO];
    _tickImage.image = [UIImage imageNamed:@"plus_"];
    _followButton.enabled = YES;
}

- (void)loadingState {
    [_activityIndicator setHidden:NO];
    [_tickImage setHidden:YES];
}

@end
