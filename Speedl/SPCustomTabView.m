//
//  SPCustomTabView.m
//  Populr
//
//  Created by Desmond McNamee on 2015-06-27.
//  Copyright (c) 2015 Speedl. All rights reserved.
//

#import "SPCustomTabView.h"

#define kSelectedSearchImage [UIImage imageNamed:@"mag"]
#define kNonSelectedSearchImage [UIImage imageNamed:@"mag_opaque"]

@interface SPCustomTabView ()

@property (strong, nonatomic) IBOutlet UIView *leftViewBottomLine;
@property (strong, nonatomic) IBOutlet UIView *centreViewBottomLine;
@property (strong, nonatomic) IBOutlet UIView *rightViewBottomLine;

@property (strong, nonatomic) IBOutlet UILabel *followingLabel;
@property (strong, nonatomic) IBOutlet UILabel *followingCountLabel;

@property (strong, nonatomic) IBOutlet UILabel *followersLabel;
@property (strong, nonatomic) IBOutlet UILabel *followersCountLabel;

@property (strong, nonatomic) IBOutlet UIView *firstVerticalLine;
@property (strong, nonatomic) IBOutlet UIView *secondVerticalLine;
@property (strong, nonatomic) IBOutlet UIView *topLine;

@property (strong, nonatomic) IBOutlet UIImageView *searchImageView;

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

- (IBAction)didPressRightView:(id)sender {
    _selectedSegmentIndex = 2;
    [self layoutSubviews];
}

- (void)awakeFromNib {
    _selectedSegmentIndex = 1;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(gotFollowingCount:)
                                                 name:kSPFollowingCountNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(gotFollowersCount:)
                                                 name:kSPFollowersCountNotification
                                               object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)gotFollowersCount:(NSNotification *)notification {
    NSNumber *numberOfFollowers = [notification object];
    _followersCountLabel.text = [numberOfFollowers stringValue];
}

- (void)gotFollowingCount:(NSNotification *)notification {
    NSNumber *numberOfFollowing = [notification object];
    _followingCountLabel.text = [numberOfFollowing stringValue];
}

- (void)setCountLabels {
    _followingCountLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)[[SPUser getFollowingArray] count]];
    _followersCountLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)[[SPUser getFollowersArray] count]];
}

- (void)layoutSubviews {
    [self setupAppearance];
    [self setCountLabels];
    
    _followersLabel.font = [SPAppearance timeLabelFont];
    _followingLabel.font = [SPAppearance timeLabelFont];
    
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
        case 2:
            [self setupForRightPress];
            break;
        default:
            break;
    }
}

- (void)setupAppearance {
    self.backgroundColor = [UIColor clearColor];
    
    _topLine.backgroundColor = [SPAppearance megaSeeThroughColour];
    _firstVerticalLine.backgroundColor = [SPAppearance megaSeeThroughColour];
    _secondVerticalLine.backgroundColor = [SPAppearance megaSeeThroughColour];
    _leftViewBottomLine.backgroundColor = [SPAppearance megaSeeThroughColour];
    _centreViewBottomLine.backgroundColor = [SPAppearance megaSeeThroughColour];
    _rightViewBottomLine.backgroundColor = [SPAppearance megaSeeThroughColour];
}

- (void)setupForLeftPress {
    [_leftViewBottomLine setHidden:YES];
    [_centreViewBottomLine setHidden:NO];
    [_rightViewBottomLine setHidden:NO];
    
    [_followersCountLabel setTextColor:[SPAppearance seeThroughColour]];
    [_followersLabel setTextColor:[SPAppearance seeThroughColour]];
    [_followingCountLabel setTextColor:[SPAppearance seeThroughColour]];
    [_followingLabel setTextColor:[SPAppearance seeThroughColour]];
    
    _searchImageView.image = kSelectedSearchImage;
}

- (void)setupForCentrePress { // Following
    [_leftViewBottomLine setHidden:NO];
    [_centreViewBottomLine setHidden:YES];
    [_rightViewBottomLine setHidden:NO];
    
    [_followersCountLabel setTextColor:[SPAppearance seeThroughColour]];
    [_followersLabel setTextColor:[SPAppearance seeThroughColour]];
    [_followingCountLabel setTextColor:[UIColor whiteColor]];
    [_followingLabel setTextColor:[UIColor whiteColor]];
    
    _searchImageView.image = kNonSelectedSearchImage;
}

- (void)setupForRightPress { // Followers
    [_leftViewBottomLine setHidden:NO];
    [_centreViewBottomLine setHidden:NO];
    [_rightViewBottomLine setHidden:YES];
    
    [_followersCountLabel setTextColor:[UIColor whiteColor]];
    [_followersLabel setTextColor:[UIColor whiteColor]];
    [_followingCountLabel setTextColor:[SPAppearance seeThroughColour]];
    [_followingLabel setTextColor:[SPAppearance seeThroughColour]];
    
    _searchImageView.image = kNonSelectedSearchImage;
}


@end
