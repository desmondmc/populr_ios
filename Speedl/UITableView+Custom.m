//
//  UITableView+Custom.m
//  Speedl
//
//  Created by Desmond McNamee on 2015-05-15.
//  Copyright (c) 2015 Speedl. All rights reserved.
//

#import "UITableView+Custom.h"

@implementation UITableView (Custom)

- (void)styleAsMainSpeedlTableView {
    self.backgroundColor = [UIColor clearColor];
    [self setSeparatorColor:[SPAppearance seeThroughColour]];
    self.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

@end
