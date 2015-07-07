//
//  SPComposeViewController.h
//  Speedle
//
//  Created by Desmond McNamee on 2015-03-15.
//  Copyright (c) 2015 Desmond McNamee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SPMessageProcessor.h"

@interface SPComposeViewController : SPContainedViewController <SPContainerViewControllerDelegate, UITextViewDelegate, SPMessageProcessorDelegate>

- (id)initWithIsFeedback:(BOOL)isFeedbackView;

@end
