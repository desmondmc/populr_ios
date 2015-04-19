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
+ (UIColor *) seeThroughColour;

+ (UIColor *) mainTextFieldColour;
+ (UIFont *) mainTextFieldFont;

+ (UIColor *) mainButtonColour;
+ (UIFont *) mainButtonFont;

+ (UIFont *) mainSegmentControlColour;
+ (UIFont *) mainSegmentControlFont;

+ (UIFont *) friendsListFont;
+ (UIColor *) friendsListColour;

@end
