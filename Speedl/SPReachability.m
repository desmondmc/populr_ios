//
//  SPReachability.m
//  Populr
//
//  Created by Desmond McNamee on 2015-10-11.
//  Copyright © 2015 Speedl. All rights reserved.
//

#import "SPReachability.h"
#import "Reachability.h"

@interface SPReachability ()

@property (strong, nonatomic) Reachability *reach;

@end

@implementation SPReachability

+ (id)sharedInstance {
    static SPReachability *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
        [sharedInstance setupReachabilityObject];
    });
    return sharedInstance;
}


- (void)setupReachabilityObject {
    // Allocate a reachability object
    _reach = [Reachability reachabilityWithHostname:@"www.gzelle.co"];
    
    // Set the blocks
    _reach.reachableBlock = ^(Reachability*reach)
    {
        // keep in mind this is called on a background thread
        _isReachable = YES;
    };
    
    _reach.unreachableBlock = ^(Reachability*reach)
    {
        _isReachable = NO;
    };
    
    // Start the notifier, which will cause the reachability object to retain itself!
    [_reach startNotifier];
}


@end
