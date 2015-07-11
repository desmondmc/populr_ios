//
//  SPSuggestionTableViewCell.m
//  Populr
//
//  Created by Desmond McNamee on 2015-07-11.
//  Copyright (c) 2015 Speedl. All rights reserved.
//

#import "SPSuggestionTableViewCell.h"

@interface SPSuggestionTableViewCell ()

@end

@implementation SPSuggestionTableViewCell

- (void)awakeFromNib {
    // Initialization code
    [self setBackgroundColor:[UIColor clearColor]];
    [self setupAppearance];
}

- (void) setupAppearance {
    [self.usernameLabel styleAsFriendLabel];
    self.usernameLabel.textColor = [SPAppearance globalBackgroundColour];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
