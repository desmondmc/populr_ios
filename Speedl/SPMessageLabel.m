//
//  SPMessageLabel.m
//  Speedle
//
//  Created by Desmond McNamee on 2015-03-15.
//  Copyright (c) 2015 Desmond McNamee. All rights reserved.
//

#import "SPMessageLabel.h"
#import "TransitionKit.h"

#define kState_Paused @"Paused"
#define kState_Playing @"Playing"

#define kEvent_Timer @"Timer"
#define kEvent_ResetPress @"ResetPress"
#define kEvent_PausePress @"PausePress"
#define kEvent_PlayPress @"PlayPress"
#define kEvent_MessageFinished @"MessageFinished"

@interface SPMessageLabel ()

@property NSArray *partsOfMessage;
@property NSTimeInterval delay;
@property BOOL stopTimerFlag;
@property NSInteger wordIndex;
@property BOOL isAnimating;
@property NSString *wordBeingDisplayed;

@property (strong, nonatomic) TKStateMachine *stateMachine;

@end

@implementation SPMessageLabel {
    SPMessageLabelCompletionBlock _completionBlock;
}

@synthesize messageText = _messageText;
@synthesize wordPerMin = _wordPerMin;

#pragma mark Public

- (void)playAnimation {
    [_stateMachine fireEvent:kEvent_PlayPress userInfo:nil error:nil];
}

- (void)playAnimationWithCompletionBlock:(SPMessageLabelCompletionBlock)block {
    _completionBlock = block;
    [_stateMachine fireEvent:kEvent_PlayPress userInfo:nil error:nil];
}

- (void)pauseAnination {
    [_stateMachine fireEvent:kEvent_PausePress userInfo:nil error:nil];
}

- (void)restartAnimation {
    [_stateMachine fireEvent:kEvent_ResetPress userInfo:nil error:nil];
}

#pragma mark Setters and Getters

- (NSString *) messageText {
    return _messageText;
}

- (void)setMessageText:(NSString *)messageText {
    if (messageText) {
        _messageText = messageText;
        
        _partsOfMessage = [_messageText componentsSeparatedByString: @" "];
        
        if ([_partsOfMessage count] > 0) {
            self.text = [_partsOfMessage objectAtIndex:0];
            [self setupStateMachine];
        }
    }
}

- (NSInteger) wordPerMin {
    return _wordPerMin;
}

- (void)setWordPerMin:(NSInteger)wordPerMin {
    _wordPerMin = wordPerMin;
    if (wordPerMin == 0) {
        _delay = 0;
        return;
    }
    _delay =  60/((NSTimeInterval)wordPerMin);
}

#pragma mark Private

- (void)incrementWordIndex {
    if (_wordIndex < [_partsOfMessage count] - 1) {
        _wordIndex++;
    } else {
        [_stateMachine fireEvent:kEvent_MessageFinished userInfo:nil error:nil];
    }
}

- (void)setupStateMachine {
    if (_stateMachine != nil) {
        return;
    }
    
    _stateMachine = [TKStateMachine new];
    
    /*### PAUSE STATE ###*/
    
    TKState *paused = [TKState stateWithName:kState_Paused];
    [paused setDidEnterStateBlock:^(TKState *state, TKTransition *transition) {
        if (![_stateMachine.currentState.name isEqualToString:kState_Paused]) {
            return;
        }
        if ([transition.event.name isEqualToString:kEvent_PausePress]) {
            //Stop timer.
            [self stopTimer];
            self.text = [_partsOfMessage objectAtIndex:_wordIndex];
        }
        if ([transition.event.name isEqualToString:kEvent_MessageFinished]) {
            [self stopTimer];
            if (_completionBlock) {
                _completionBlock();
            }
        }
        
        if ([transition.event.name isEqualToString:kEvent_ResetPress]) {
            _wordIndex = 0;
            self.text = [_partsOfMessage objectAtIndex:_wordIndex];
        }
    }];
    
    /*### PLAYING STATE ###*/
    
    TKState *playing = [TKState stateWithName:kState_Playing];
    [playing setDidEnterStateBlock:^(TKState *state, TKTransition *transition) {
        if (![_stateMachine.currentState.name isEqualToString:kState_Playing]) {
            return;
        }
        if ([transition.sourceState.name isEqualToString:kState_Paused]) {
            //Start timer.
            [self startTimer];
        }
        if ([transition.event.name isEqualToString:kEvent_Timer]) {
            //Increment wordCount
            [self incrementWordIndex];
        }
        _wordBeingDisplayed = self.text;
        self.text = [_partsOfMessage objectAtIndex:_wordIndex];
    }];
    
    [_stateMachine addStates:@[ paused, playing ]];
    _stateMachine.initialState = paused;
    
    TKEvent *timerEvent = [TKEvent eventWithName:kEvent_Timer transitioningFromStates:@[ playing ] toState:playing];
    TKEvent *resetPressEvent = [TKEvent eventWithName:kEvent_ResetPress transitioningFromStates:@[ paused ] toState:paused];
    TKEvent *pausePressEvent = [TKEvent eventWithName:kEvent_PausePress transitioningFromStates:@[ playing ] toState:paused];
    TKEvent *playPressEvent = [TKEvent eventWithName:kEvent_PlayPress transitioningFromStates:@[ paused ] toState:playing];
    TKEvent *messageFinished = [TKEvent eventWithName:kEvent_MessageFinished transitioningFromStates:@[ playing ] toState:paused];
    
    [_stateMachine addEvents:@[ timerEvent, resetPressEvent, pausePressEvent, playPressEvent, messageFinished ]];
    
}

- (void) startTimer {
    _stopTimerFlag = NO;
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        while (_stopTimerFlag != YES) {

            [NSThread sleepForTimeInterval:_delay];
            
            if ([self.text hasSuffix:@"."]
                || [self.text hasSuffix:@"!"]
                || [self.text hasSuffix:@"?"]
                || [self.text hasSuffix:@";"]
                || [self.text hasSuffix:@":"]) {
                
                [NSThread sleepForTimeInterval:_delay];
            } else if ([self.text hasSuffix:@","]) {
                [NSThread sleepForTimeInterval:_delay*0.5];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^(void){
                [_stateMachine fireEvent:kEvent_Timer userInfo:nil error:nil];
            });
        }
    });
}

- (void) stopTimer {
    _stopTimerFlag = YES;
}

@end
