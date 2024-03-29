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

#define kMainColourKey @"mainColourKey"
#define kSecondColourKey @"secondColourKey"

#define kColourArray @[@{kMainColourKey:@0x47b36c, kSecondColourKey:@0x9742c0},@{kMainColourKey:@0x4783b3, kSecondColourKey:@0x90323c},@{kMainColourKey:@0xabb347, kSecondColourKey:@0x425cc0},@{kMainColourKey:@0x479db3, kSecondColourKey:@0xc04283},@{kMainColourKey:@0xb347a3, kSecondColourKey:@0xc0a042},@{kMainColourKey:@0x47b355, kSecondColourKey:@0x8142c0},@{kMainColourKey:@0xb34747, kSecondColourKey:@0xc0c042},@{kMainColourKey:@0x95b347, kSecondColourKey:@0x424bc0},@{kMainColourKey:@0x7c47b3, kSecondColourKey:@0xc08342},@{kMainColourKey:@0xb3a147, kSecondColourKey:@0x328290},@{kMainColourKey:@0xb38c47, kSecondColourKey:@0x42c07b},@{kMainColourKey:@0x67b347, kSecondColourKey:@0x5e42c0},@{kMainColourKey:@0x47b39c, kSecondColourKey:@0xc042b4},@{kMainColourKey:@0x4e47b3, kSecondColourKey:@0xc05e42},@{kMainColourKey:@0xb37747, kSecondColourKey:@0x48c042},@{kMainColourKey:@0x9347b3, kSecondColourKey:@0xcca668},@{kMainColourKey:@0xb35e47, kSecondColourKey:@0x87c042},@{kMainColourKey:@0x476eb3, kSecondColourKey:@0xd98e96},@{kMainColourKey:@0xab47b3, kSecondColourKey:@0xccad68},@{kMainColourKey:@0xb34777, kSecondColourKey:@0xc0af42},@{kMainColourKey:@0x4eb347, kSecondColourKey:@0x7142c0},@{kMainColourKey:@0xb3478e, kSecondColourKey:@0xc0a842},@{kMainColourKey:@0x47b383, kSecondColourKey:@0xb042c0},@{kMainColourKey:@0x4757b3, kSecondColourKey:@0xcc6f68},@{kMainColourKey:@0x6547b3, kSecondColourKey:@0xc07142},@{kMainColourKey:@0x7cb347, kSecondColourKey:@0x4e42c0},@{kMainColourKey:@0x47b3b3, kSecondColourKey:@0xc0429b},@{kMainColourKey:@0xb3475e, kSecondColourKey:@0xc0b842}]

@implementation SPAppearance

+ (UIColor *) globalBackgroundColour {
    return [self getMainBackgroundColour];
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

+ (UIFont *) sendButtonFont {
    return [UIFont fontWithName:@"HelveticaNeue-Bold" size:32];
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
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue-BoldItalic" size:16];
    return font;
}

+ (UIFont *) friendsListFont {
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:16];
    return font;
}

+ (UIFont *) helpLabelFont {
    UIFont *font = [UIFont fontWithName:@"Helvetica Neue" size:16];
    return font;
}

+ (UIFont *) timeLabelFont {
    UIFont *font = [UIFont fontWithName:@"Helvetica Neue" size:16];
    return font;
}

+ (UIFont *) friendsCountLabelFont {
    UIFont *font = [UIFont fontWithName:@"Helvetica Neue" size:34];
    return font;
}

+ (UIColor *) friendsListColour {
    return [UIColor whiteColor];
}



#pragma mark - Helpers

+ (UIColor *) getMainBackgroundColour {
    NSInteger numberOfDays = [self getColorIndex];

    NSInteger colourIndex = numberOfDays % [kColourArray count];
    return [self getColourAtIndex:colourIndex key:kMainColourKey];
}

+ (UIColor *)getOppositeColourForToday {
    NSInteger numberOfDays = [self getColorIndex];
    
    NSInteger colourIndex = numberOfDays % [kColourArray count];
    return [self getColourAtIndex:colourIndex key:kSecondColourKey];
}

+ (UIColor *)getColourAtIndex:(NSInteger)index key:(NSString *)key {
    NSInteger colorValue = [kColourArray[index][key] integerValue];
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
