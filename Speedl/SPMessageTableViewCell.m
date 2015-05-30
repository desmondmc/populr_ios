//
//  SPMessageTableViewCell.m
//  Speedl
//
//  Created by Desmond McNamee on 2015-04-18.
//  Copyright (c) 2015 Speedl. All rights reserved.
//

#import "SPMessageTableViewCell.h"

@implementation SPMessageTableViewCell

- (void)awakeFromNib {
    // Initialization code
    self.messageNumberLabel.font = [SPAppearance mainSegmentControlFont];
    self.messageNumberLabel.textColor = [UIColor whiteColor];
    self.messageTimeLabel.font = [SPAppearance timeLabelFont];
    self.messageTimeLabel.textColor = [SPAppearance seeThroughColour];
    [self.activityIndicator setHidden:YES];
    [self.activityIndicator startAnimating];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [self.activityIndicator startAnimating];
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
