//
//  SPAppearance.m
//  Speedl
//
//  Created by Desmond McNamee on 2015-04-18.
//  Copyright (c) 2015 Speedl. All rights reserved.
//

#import "SPAppearance.h"

@implementation SPAppearance

+ (UIColor *) globalBackgroundColour {
    return [UIColor colorWithRed:0.18 green:0.18 blue:0.22 alpha:1]; // Dark Grey
    //return [UIColor colorWithRed:0.737 green:0.365 blue:0.475 alpha:1]; // Pink
}

+ (UIColor *) seeThroughColour {
    return [UIColor colorWithRed:1 green:1 blue:1 alpha:0.40];
}

+ (UIFont *) mainTextFieldFont {
    return [UIFont fontWithName:@"Helvetica Neue" size:35];
}

+ (UIColor *) mainTextFieldColour {
    return [UIColor whiteColor];
}

+ (UIColor *) mainButtonColour {
    return [UIColor whiteColor];
}

+ (UIFont *) mainButtonFont {
    UIFont *font = [UIFont fontWithName:@"Helvetica-BoldOblique" size:20];
    return font;
}

+ (UIFont *) mainSegmentControlColour {
    return nil;
}

+ (UIFont *) mainSegmentControlFont {
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue-BoldItalic" size:15];
    return font;
}

@end
