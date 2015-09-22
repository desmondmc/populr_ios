//
//  SPAppearance.h
//  Speedl
//
//  Created by Desmond McNamee on 2015-04-18.
//  Copyright (c) 2015 Speedl. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SPAppearance : NSObject

+ (UIColor *) globalBackgroundColour;
+ (UIColor *) globalBackgroundColourWithAlpha:(CGFloat)alpha;
+ (UIColor *) seeThroughColour;
+ (UIColor *) megaSeeThroughColour;

+ (UIFont *) sendButtonFont;
+ (UIFont *) helpLabelFont;

+ (UIColor *) mainTextFieldColour;
+ (UIFont *) mainTextFieldFont;

+ (UIColor *) mainButtonColour;
+ (UIFont *) mainButtonFont;

+ (UIFont *) mainSegmentControlColour;
+ (UIFont *) mainSegmentControlFont;

+ (UIFont *) friendsListFont;
+ (UIColor *) friendsListColour;

+ (UIColor *) getMainBackgroundColour;
+ (UIColor *) getFirstColourForToday;
+ (UIColor *) getSecondColourForToday;
+ (UIColor *) getThirdColourForToday;

+ (UIFont *) timeLabelFont;

@end
