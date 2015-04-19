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

- (void) styleAsFriendLabel {
    self.font = [SPAppearance friendsListFont];
    self.textColor = [SPAppearance friendsListColour];
    self.text = [self.text uppercaseString];
}

@end
