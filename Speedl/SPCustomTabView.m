//
//  SPCustomTabView.m
//  Populr
//
//  Created by Desmond McNamee on 2015-06-27.
//  Copyright (c) 2015 Speedl. All rights reserved.
//

#import "SPCustomTabView.h"

#define kSelectedSearchImage [UIImage imageNamed:@"mag_glass_active"]
#define kNonSelectedSearchImage [UIImage imageNamed:@"mag_glass_inactive"]
#define kSelectedFriendsImage [UIImage imageNamed:@"friends_icon_active"]
#define kNonSelectedFriendsImage [UIImage imageNamed:@"friends_icon_inactive"]

@interface SPCustomTabView ()

@property (strong, nonatomic) IBOutlet UIView *leftViewBottomLine;
@property (strong, nonatomic) IBOutlet UIView *centreViewBottomLine;



@property (strong, nonatomic) IBOutlet UIView *firstVerticalLine;
@property (strong, nonatomic) IBOutlet UIView *topLine;

@property (strong, nonatomic) IBOutlet UIImageView *searchImageView;
@property (strong, nonatomic) IBOutlet UIImageView *friendsImageView;

@end

@implementation SPCustomTabView

- (IBAction)didPressLeftView:(id)sender {
    _selectedSegmentIndex = 0;
    [self layoutSubviews];
}

- (IBAction)didPressCentreView:(id)sender {
    _selectedSegmentIndex = 1;
    [self layoutSubviews];
}

- (void)awakeFromNib {
    _selectedSegmentIndex = 1;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)layoutSubviews {
    [self setupAppearance];
    
    if (_delegate) {
        [_delegate tabSelectedAtIndex:_selectedSegmentIndex];
    }
    
    switch (_selectedSegmentIndex) {
        case 0:
            [self setupForLeftPress];
            break;
        case 1:
            [self setupForCentrePress];
            break;
        default:
            break;
    }
}

- (void)setupAppearance {
    self.backgroundColor = [UIColor clearColor];
    
    _topLine.backgroundColor = [SPAppearance megaSeeThroughColour];
    _firstVerticalLine.backgroundColor = [SPAppearance megaSeeThroughColour];
    _leftViewBottomLine.backgroundColor = [SPAppearance megaSeeThroughColour];
    _centreViewBottomLine.backgroundColor = [SPAppearance megaSeeThroughColour];
}

- (void)setupForLeftPress {
    [_leftViewBottomLine setHidden:YES];
    [_centreViewBottomLine setHidden:NO];
    
    _friendsImageView.image = kNonSelectedFriendsImage;
    _searchImageView.image = kSelectedSearchImage;
}

- (void)setupForCentrePress { // Following
    [_leftViewBottomLine setHidden:NO];
    [_centreViewBottomLine setHidden:YES];
    
    _friendsImageView.image = kSelectedFriendsImage;
    _searchImageView.image = kNonSelectedSearchImage;
}


@end
