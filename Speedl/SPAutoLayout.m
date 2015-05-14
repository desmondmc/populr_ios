//
//  SPAutoLayout.m
//  Speedl
//
//  Created by Desmond McNamee on 2015-05-14.
//  Copyright (c) 2015 Speedl. All rights reserved.
//

#import "SPAutoLayout.h"

@implementation SPAutoLayout

+ (void)constrainSubviewToFillSuperview:(UIView *)subview
{
    [subview alignTop:@"0" bottom:@"0" toView:[subview superview]];
    [subview alignLeading:@"0" trailing:@"0" toView:[subview superview]];
    
    [subview constrainWidthToView:[subview superview] predicate:nil];
    [subview constrainHeightToView:[subview superview] predicate:nil];
    
    [[subview superview] layoutIfNeeded];
}

@end
