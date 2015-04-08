//
//  ContainerViewController.h
//  SwipeViewsTest
//
//  Created by Desmond McNamee on 2015-03-26.
//  Copyright (c) 2015 Speedl. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SPContainerViewControllerDelegate <NSObject>

@optional

- (void) newVisableViewController:(UIViewController *)viewController;

@end

@interface SPContainerViewController : UIViewController <UIPageViewControllerDataSource, UIPageViewControllerDelegate, UIScrollViewDelegate>

@property (nonatomic, strong) NSMutableArray *viewControllerArray;
@property (strong, nonatomic) UIPageViewController *pageController;

- (void) goToMessageViewController;

- (void) goToComposeViewControllerFromLeft;
- (void) goToComposeViewControllerFromRight;

- (void) goToFriendsViewController;

- (void) addDelegate:(id <SPContainerViewControllerDelegate>)delegate;
- (void) removeDelegate:(id <SPContainerViewControllerDelegate>)delegate;

@end


