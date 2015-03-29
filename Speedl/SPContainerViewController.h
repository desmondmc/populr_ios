//
//  ContainerViewController.h
//  SwipeViewsTest
//
//  Created by Desmond McNamee on 2015-03-26.
//  Copyright (c) 2015 Speedl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SPContainerViewController : UIViewController <UIPageViewControllerDataSource, UIPageViewControllerDelegate, UIScrollViewDelegate>

@property (nonatomic, strong) NSMutableArray *viewControllerArray;
@property (strong, nonatomic) UIPageViewController *pageController;

@end
