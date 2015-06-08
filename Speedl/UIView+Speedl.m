//
//  UIView+Speedl.m
//  gzelle
//
//  Created by Desmond McNamee on 2015-06-08.
//  Copyright (c) 2015 Speedl. All rights reserved.
//

#import "UIView+Speedl.h"

@implementation UIView (Speedl)

+ (instancetype)viewWithDerivedNibName
{
    UIView *view = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:nil options:nil] lastObject];
    
    NSAssert1([view isKindOfClass:[self class]], @"XIB root view needs to be of type %@", NSStringFromClass([self class]));
    
    return view;
}

+ (UINib *)nib
{
    return [UINib nibWithNibName:NSStringFromClass([self class]) bundle:nil];
}

+ (NSString *)reuseIdentifier
{
    return NSStringFromClass([self class]);
}

@end
