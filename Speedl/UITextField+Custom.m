//
//  UITextField+Custom.m
//  Speedl
//
//  Created by Desmond McNamee on 2015-04-18.
//  Copyright (c) 2015 Speedl. All rights reserved.
//

#import "UITextField+Custom.h"

@implementation UITextField (Custom)

- (void) styleAsMainSpeedlTextField {

    // Style Placeholder Text
    if (self.placeholder) {
        self.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.placeholder attributes:@{NSForegroundColorAttributeName: [SPAppearance seeThroughColour]}];
    }

    self.font = [SPAppearance mainTextFieldFont];
    
    self.textColor = [SPAppearance mainTextFieldColour];
}

@end
