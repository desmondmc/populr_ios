//
//  SPMessageLabel.h
//  Speedle
//
//  Created by Desmond McNamee on 2015-03-15.
//  Copyright (c) 2015 Desmond McNamee. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^SPMessageLabelCompletionBlock)();

@interface SPMessageLabel : UILabel

@property NSString *messageText;
@property NSInteger wordPerMin;

- (void)playAnimation;
- (void)playAnimationWithCompletionBlock:(SPMessageLabelCompletionBlock)block;

- (void)pauseAnination;
- (void)restartAnimation;
- (void)finishAnimation;


@end
