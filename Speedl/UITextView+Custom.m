//
//  UITextView+Custom.m
//  Speedl
//
//  Created by Desmond McNamee on 2015-04-19.
//  Copyright (c) 2015 Speedl. All rights reserved.
//

#import "UITextView+Custom.h"

@implementation UITextView (Custom)

- (void)styleAsMainSpeedlTextView {
    self.font = [SPAppearance mainTextFieldFont];
    self.textColor = [SPAppearance mainTextFieldColour];
}

- (NSMutableAttributedString *)mutableAttributedString {
    return [[NSMutableAttributedString alloc] initWithAttributedString: self.attributedText];
}



@end
