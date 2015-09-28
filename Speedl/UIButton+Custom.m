//
//  UIButton+Custom.m
//  Speedl
//
//  Created by Desmond McNamee on 2015-04-18.
//  Copyright (c) 2015 Speedl. All rights reserved.
//

#import "UIButton+Custom.h"

@implementation UIButton (Custom)

- (void) styleAsMainSpeedlButton {
    self.titleLabel.font = [SPAppearance sendButtonFont];
    self.titleLabel.textColor = [SPAppearance globalBackgroundColour];
}

@end
