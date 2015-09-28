//
//  SPCustomTabView.h
//  Populr
//
//  Created by Desmond McNamee on 2015-06-27.
//  Copyright (c) 2015 Speedl. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, SPTabViewType) {
    SPTabViewTypeFriends,
    SPTabViewTypeLogin
};

@protocol SPCustomTabViewDelegate <NSObject>

- (void)tabSelectedAtIndex:(NSInteger)index;

@end

@interface SPCustomTabView : UIView

- (id)initWithTabViewType:(SPTabViewType)type;

@property (nonatomic) NSInteger selectedSegmentIndex;
@property (weak, nonatomic) id<SPCustomTabViewDelegate> delegate;

@end
