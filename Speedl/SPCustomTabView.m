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

@property (strong, nonatomic) IBOutlet UILabel *friendsLabel;
@property (strong, nonatomic) IBOutlet UILabel *friendsCountLabel;

@property (strong, nonatomic) IBOutlet UIView *firstVerticalLine;
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

- (void)awakeFromNib {
    _selectedSegmentIndex = 1;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(gotFriendsCount:)
                                                 name:kSPFriendsCountNotification
                                               object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)gotFriendsCount:(NSNotification *)notification {
    NSNumber *numberOfFollowing = [notification object];
    _friendsCountLabel.text = [numberOfFollowing stringValue];
}

- (void)setCountLabels {
    _friendsCountLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)[[SPUser getFriendsArray] count]];
}

- (void)layoutSubviews {
    [self setupAppearance];
    [self setCountLabels];
    
    _friendsLabel.font = [SPAppearance timeLabelFont];
    
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
    
    [_friendsCountLabel setTextColor:[SPAppearance seeThroughColour]];
    [_friendsLabel setTextColor:[SPAppearance seeThroughColour]];
    
    _searchImageView.image = kSelectedSearchImage;
}

- (void)setupForCentrePress { // Following
    [_leftViewBottomLine setHidden:NO];
    [_centreViewBottomLine setHidden:YES];
    
    [_friendsCountLabel setTextColor:[SPAppearance seeThroughColour]];
    [_friendsLabel setTextColor:[SPAppearance seeThroughColour]];
    
    _searchImageView.image = kNonSelectedSearchImage;
}


@end
