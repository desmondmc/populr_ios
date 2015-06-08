//
//  UIView+Speedl.h
//  gzelle
//
//  Created by Desmond McNamee on 2015-06-08.
//  Copyright (c) 2015 Speedl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Speedl)

+ (instancetype)viewWithDerivedNibName;

+ (UINib *)nib;

+ (NSString *)reuseIdentifier;

@end
