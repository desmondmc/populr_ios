//
//  SPCustomPageControl.m
//  gzelle
//
//  Created by Desmond McNamee on 2015-06-08.
//  Copyright (c) 2015 Speedl. All rights reserved.
//

#import "SPCustomPageControl.h"

@interface SPCustomPageControl ()
@property (strong, nonatomic) IBOutlet UIView *circle1;
@property (strong, nonatomic) IBOutlet UIView *circle2;
@property (strong, nonatomic) IBOutlet UIView *circle3;
@property (strong, nonatomic) IBOutlet UIView *innerCircle1;

@end

@implementation SPCustomPageControl

- (void)colourCircleAtIndex:(NSInteger)index {
    switch (index) {
        case 0:
            _circle1.backgroundColor = [UIColor whiteColor];
            _circle2.backgroundColor = [SPAppearance seeThroughColour];
            _circle3.backgroundColor = [SPAppearance seeThroughColour];
            break;
            
        case 1:
            _circle1.backgroundColor = [SPAppearance seeThroughColour];
            _circle2.backgroundColor = [UIColor whiteColor];
            _circle3.backgroundColor = [SPAppearance seeThroughColour];
            break;
            
        case 2:
            _circle1.backgroundColor = [SPAppearance seeThroughColour];
            _circle2.backgroundColor = [SPAppearance seeThroughColour];
            _circle3.backgroundColor = [UIColor whiteColor];
            break;
            
        default:
            break;
    }
}

-(void)awakeFromNib {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotMessageCount:) name:kSPMessageCountNotification object:nil];
}

- (void)gotMessageCount:(NSNotification *)notification {
    NSNumber *numberOfMessages = [notification object];
    if (numberOfMessages.integerValue > 0) {
        [self turnOnNotification];
    } else {
        [self turnOffNotification];
    }
}

- (void)turnOnNotification {
    [_innerCircle1 setHidden:NO];
}

- (void)turnOffNotification {
    [_innerCircle1 setHidden:YES];
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
