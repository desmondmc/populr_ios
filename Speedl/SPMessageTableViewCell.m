//
//  SPMessageTableViewCell.m
//  Speedl
//
//  Created by Desmond McNamee on 2015-04-18.
//  Copyright (c) 2015 Speedl. All rights reserved.
//

#import "SPMessageTableViewCell.h"

#define kSecondsInAMin 60
#define kSecondsInAnHour 3600
#define kSecondsInADay 86400

@implementation SPMessageTableViewCell

- (void)awakeFromNib {
    // Initialization code
    self.messageNumberLabel.font = [SPAppearance mainSegmentControlFont];
    self.messageNumberLabel.textColor = [SPAppearance globalBackgroundColour];
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

- (void)setupWithMessage:(SPMessage *)message {
    // Set message age label
    [NSDateFormatter setDefaultFormatterBehavior:NSDateFormatterBehavior10_4];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSz"];
    NSDate *messageDate = [dateFormatter dateFromString:message.timestamp];
    NSDate *now = [NSDate new];
    NSTimeInterval distanceBetweenDatesSeconds = [now timeIntervalSinceDate:messageDate];
    [self setTimeSinceLabel:distanceBetweenDatesSeconds];
    
    if ([message.type isEqualToString:@"direct"]) {
        [_mentionImage setHidden:NO];
    } else {
        [_mentionImage setHidden:YES];
    }
}

- (void) setTimeSinceLabel:(NSTimeInterval)ageOfMessageSeconds {
    NSString *timeLabel = nil;
    NSInteger ageOfMessageSecondsInt = (NSInteger)ageOfMessageSeconds;
    if (ageOfMessageSecondsInt < kSecondsInAMin) {
        timeLabel = [NSString stringWithFormat:@"%ld seconds", (long)ageOfMessageSecondsInt];
    } else if (ageOfMessageSecondsInt < kSecondsInAnHour) {
        NSInteger ageOfMessageMinutes = ageOfMessageSecondsInt/kSecondsInAMin;
        
        if (ageOfMessageMinutes == 1) {
            timeLabel = [NSString stringWithFormat:@"%ld minute", (long)ageOfMessageMinutes];
        } else {
            timeLabel = [NSString stringWithFormat:@"%ld minutes", (long)ageOfMessageMinutes];
        }
    } else if (ageOfMessageSecondsInt < kSecondsInADay) {
        NSInteger ageOfMessageHours = ageOfMessageSecondsInt/kSecondsInAnHour;
        
        if (ageOfMessageHours == 1) {
            timeLabel = [NSString stringWithFormat:@"%ld hour", (long)ageOfMessageHours];
        } else {
            timeLabel = [NSString stringWithFormat:@"%ld hours", (long)ageOfMessageHours];
        }
    } else {
        NSInteger ageOfMessageDays = ageOfMessageSecondsInt/kSecondsInADay;
        
        if (ageOfMessageDays == 1) {
            timeLabel = [NSString stringWithFormat:@"%ld day", (long)ageOfMessageDays];
        } else {
            timeLabel = [NSString stringWithFormat:@"%ld days", (long)ageOfMessageDays];
        }
    }
    
    _messageTimeLabel.text = timeLabel;
}

@end
