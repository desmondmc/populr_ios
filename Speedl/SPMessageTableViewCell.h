//
//  SPMessageTableViewCell.h
//  Speedl
//
//  Created by Desmond McNamee on 2015-04-18.
//  Copyright (c) 2015 Speedl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SPMessageTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *messageNumberLabel;
@property (strong, nonatomic) IBOutlet UILabel *messageTimeLabel;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) IBOutlet UIImageView *mentionImage;
@property (strong, nonatomic) IBOutlet UIView *circleView;

- (void)setupWithMessage:(SPMessage *)message;

@end
