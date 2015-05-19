//
//  UISegmentedControl+Custom.m
//  Speedl
//
//  Created by Desmond McNamee on 2015-04-18.
//  Copyright (c) 2015 Speedl. All rights reserved.
//

#import "UISegmentedControl+Custom.h"

@implementation UISegmentedControl (Custom)

- (void) styleAsMainSpeedlSegmentControl {
    UIFont *font = [SPAppearance timeLabelFont];
    NSDictionary *attributes = [NSDictionary dictionaryWithObject:font
                                                           forKey:NSFontAttributeName];
    [self setTitleTextAttributes:attributes forState:UIControlStateNormal];
}

@end
