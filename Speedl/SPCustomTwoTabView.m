//
//  SPCustomTwoTapView.m
//  Speedl
//
//  Created by Desmond McNamee on 2015-04-22.
//  Copyright (c) 2015 Speedl. All rights reserved.
//

#import "SPCustomTwoTabView.h"
@interface SPCustomTwoTabView ()

@property (strong, nonatomic) IBOutlet UIView *topLineView;
@property (strong, nonatomic) IBOutlet UIView *centerLineView;
@property (strong, nonatomic) IBOutlet UIView *leftBottomLine;
@property (strong, nonatomic) IBOutlet UIButton *leftButton;
@property (strong, nonatomic) IBOutlet UIView *rightBottomLine;
@property (strong, nonatomic) IBOutlet UIButton *rightButton;

@end

@implementation SPCustomTwoTabView

-(void)setupView {
    _topLineView.backgroundColor = [SPAppearance seeThroughColour];
    _centerLineView.backgroundColor = [SPAppearance seeThroughColour];
    _leftBottomLine.backgroundColor = [SPAppearance seeThroughColour];
    _rightBottomLine.backgroundColor = [SPAppearance seeThroughColour];
    [_rightButton styleAsMainSpeedlButton];
    [_leftButton styleAsMainSpeedlButton];
}

- (IBAction)didPressLeftButton:(id)sender {
    
}

- (IBAction)didPressRightButton:(id)sender {
    
}

@end
