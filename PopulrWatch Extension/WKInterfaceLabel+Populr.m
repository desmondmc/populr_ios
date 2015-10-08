//
//  WKInterfaceLabel+Populr.m
//  Populr
//
//  Created by Desmond McNamee on 2015-10-07.
//  Copyright © 2015 Speedl. All rights reserved.
//

#import "WKInterfaceLabel+Populr.h"
#import "UIKit/UIKit.h"

@implementation WKInterfaceLabel (Populr)

-(void)setText:(NSString *)text withSize:(CGFloat)size {
    UIFont *font = [UIFont fontWithName:@"Helvetica" size:size];
    NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObject:font
                                                                forKey:NSFontAttributeName];
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:text attributes:attrsDictionary];
    [self setAttributedText:attrString];
}

@end
