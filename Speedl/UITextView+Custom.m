//
//  UITextView+Custom.m
//  Speedl
//
//  Created by Desmond McNamee on 2015-04-19.
//  Copyright (c) 2015 Speedl. All rights reserved.
//

#import "UITextView+Custom.h"

@implementation UITextView (Custom)

- (NSMutableAttributedString *) styleAsMainSpeedlTextView {
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]initWithString:self.text];
    [attributedString addAttribute:NSForegroundColorAttributeName
                             value:[SPAppearance mainTextFieldColour]
                             range:NSMakeRange(0, [self.text length])];
    [attributedString addAttribute:NSFontAttributeName
                             value:[SPAppearance mainTextFieldFont]
                             range:NSMakeRange(0, [self.text length])];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init] ;
    [paragraphStyle setAlignment:NSTextAlignmentCenter];
    [attributedString addAttribute:NSParagraphStyleAttributeName
                             value:paragraphStyle
                             range:NSMakeRange(0, [self.text length])];
    [self setAttributedText:attributedString];
    return attributedString;
}



@end
