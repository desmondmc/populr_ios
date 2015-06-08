//
//  SPCircleView.m
//  gzelle
//
//  Created by Desmond McNamee on 2015-06-08.
//  Copyright (c) 2015 Speedl. All rights reserved.
//

#import "SPCircleView.h"

@implementation SPCircleView

- (void)setup
{
    CGFloat outerCircleCornerRadius = [self frame].size.width / 2;
    [[self layer] setCornerRadius:outerCircleCornerRadius];
}

-(void)layoutSubviews
{
    [self setup];
}

@end
