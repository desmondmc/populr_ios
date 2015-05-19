//
//  UILabel+Custom.m
//  Speedl
//
//  Created by Desmond McNamee on 2015-04-18.
//  Copyright (c) 2015 Speedl. All rights reserved.
//

#import "UILabel+Custom.h"

@implementation UILabel (Custom)

- (void) styleAsMainSpeedlLabel {

}

- (void)styleAsFriendLabel {
    self.font = [SPAppearance friendsListFont];
    self.textColor = [SPAppearance friendsListColour];
    self.text = [self.text uppercaseString];
}

- (void)styleAsFollowLabel {
    self.font = [SPAppearance friendsListFont];
    self.textColor = [SPAppearance friendsListColour];
    self.text = [self.text uppercaseString];
}

- (void)styleAsFollowingLabel {
    self.font = [SPAppearance friendsListFont];
    self.textColor = [SPAppearance seeThroughColour];
    self.text = [self.text uppercaseString];
}

- (void)styleAsTimeLabel {
    self.font = [SPAppearance timeLabelFont];
    self.textColor = [SPAppearance seeThroughColour];
}

@end
