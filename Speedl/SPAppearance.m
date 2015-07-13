//
//  SPAppearance.m
//  Speedl
//
//  Created by Desmond McNamee on 2015-04-18.
//  Copyright (c) 2015 Speedl. All rights reserved.
//

#import "SPAppearance.h"

#define UIColorFromRGB(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define kColourArray @[@0xB37D7D, @0xB3887D, @0xB3927D, @0xB39D7D, @0xB3A97D, @0xB3B37D, @0xA7B37D, @0x9DB37D, @0x90B37D, @0x86B37D, @0x7DB37D, @0x7DB388, @0x7DB392, @0x7DB39D, @0x7DB3A7, @0x7DB3B3, @0x7DA7B3, @0x7D9DB3, @0x7D92B3, @0x7D88B3, @0x7D7DB3, @0x887DB3, @0x927DB3, @0x9D7DB3, @0xA77DB3, @0xB37DB3, @0xB37DA7, @0xB37D9D]

@implementation SPAppearance

+ (UIColor *) globalBackgroundColour {
    return [self getMainBackgroundColour];
}

+ (UIColor *) globalBackgroundColourWithAlpha:(CGFloat)alpha {
    UIColor *alphaColour = [[self getFirstColourForToday] colorWithAlphaComponent:alpha];
    return alphaColour;
}

+ (UIColor *) seeThroughColour {
    return [UIColor colorWithRed:1 green:1 blue:1 alpha:0.60];
}

+ (UIColor *) megaSeeThroughColour {
    return [UIColor colorWithRed:1 green:1 blue:1 alpha:0.30];
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

+ (UIFont *) friendsListFont {
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:15];
    return font;
}

+ (UIFont *) timeLabelFont {
    UIFont *font = [UIFont fontWithName:@"Helvetica Neue" size:15];
    return font;
}

+ (UIColor *) friendsListColour {
    return [UIColor whiteColor];
}

#pragma mark - Helpers

+ (UIColor *) getMainBackgroundColour {
    NSInteger numberOfDays = [self getColorIndex];

    NSInteger colourIndex = numberOfDays % [kColourArray count];
    return [self getColourAtIndex:colourIndex];
}

+ (UIColor *) getFirstColourForToday {
    return [UIColor clearColor];
//    NSInteger numberOfDays = [self getColorIndex];
//    
//    NSInteger colourIndex = numberOfDays % [kColourArray count];
//    return [self getColourAtIndex:colourIndex];
}

+ (UIColor *) getSecondColourForToday {
    return [UIColor clearColor];
//    NSInteger numberOfDays = [self getColorIndex] + 1;
//    
//    NSInteger colourIndex = numberOfDays % [kColourArray count];
//    return [self getColourAtIndex:colourIndex];
}

+ (UIColor *) getThirdColourForToday {
    return [UIColor clearColor];
//    NSInteger numberOfDays = [self getColorIndex] + 2;
//    
//    NSInteger colourIndex = numberOfDays % [kColourArray count];
//    return [self getColourAtIndex:colourIndex];
}

+ (UIColor *)getColourAtIndex:(NSInteger)index {
    NSInteger colorValue = [kColourArray[index] integerValue];
    return UIColorFromRGB(colorValue);
}

+ (NSInteger)getColorIndex {
    NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:1429563808];//4/20/2015
    NSDate *currentDate = [NSDate date];
    
    return [self daysBetweenDate:startDate andDate:currentDate];
}

+ (NSInteger)daysBetweenDate:(NSDate*)fromDateTime andDate:(NSDate*)toDateTime
{
    NSDate *fromDate;
    NSDate *toDate;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&fromDate
                 interval:NULL forDate:fromDateTime];
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&toDate
                 interval:NULL forDate:toDateTime];
    
    NSDateComponents *difference = [calendar components:NSCalendarUnitDay
                                               fromDate:fromDate toDate:toDate options:0];
    
    return [difference day];
}

@end
