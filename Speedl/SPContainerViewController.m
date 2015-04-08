//
//  ContainerViewController.m
//  SwipeViewsTest
//
//  Created by Desmond McNamee on 2015-03-26.
//  Copyright (c) 2015 Speedl. All rights reserved.
//

#import "SPContainerViewController.h"
#import "SPComposeViewController.h"
#import "SPMessageViewController.h"
#import "SPFriendsViewController.h"

@interface SPContainerViewController ()

@property UIScrollView *scrollView;
@property NSInteger currentPageIndex;

@end

@implementation SPContainerViewController

- (void)viewDidLoad {    
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor blueColor]];
    
    self.pageController.dataSource = self;
    [[self.pageController view] setFrame:[[self view] bounds]];
    
    SPComposeViewController *mainViewController = [self.viewControllerArray objectAtIndex:1];
    
    NSArray *viewControllers = [NSArray arrayWithObject:mainViewController];
    
    [self.pageController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionReverse animated:NO completion:nil];
    
    [self addChildViewController:self.pageController];
    [[self view] addSubview:[self.pageController view]];
    [self.pageController didMoveToParentViewController:self];
    
    //This stops bouncing!
    for (UIView *view in self.pageController.view.subviews ) {
        if ([view isKindOfClass:[UIScrollView class]]) {
            UIScrollView *scroll = (UIScrollView *)view;
            scroll.delegate = self;
        }
    }
    
    self.currentPageIndex = 1;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSInteger index = [self indexOfController:viewController];
    
    if ((index == NSNotFound) || (index == 0)) {
        return nil;
    }
    
    index--;
    return [self.viewControllerArray objectAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSInteger index = [self indexOfController:viewController];
    
    if (index == NSNotFound) {
        return nil;
    }
    index++;
    
    if (index == [self.viewControllerArray count]) {
        return nil;
    }
    return [self.viewControllerArray objectAtIndex:index];
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
{
    UIViewController *vc = [pageViewController.viewControllers lastObject];
}

-(NSInteger)indexOfController:(UIViewController *)viewController
{
    for (int i = 0; i<[self.viewControllerArray count]; i++) {
        if (viewController == [self.viewControllerArray objectAtIndex:i])
        {
            self.currentPageIndex = i;
            return i;
        }
    }
    return NSNotFound;
}

#pragma mark Public Functions
- (void) goToMessageViewController {
    SPMessageViewController *messageViewController = [self.viewControllerArray objectAtIndex:0];
    
    NSArray *viewControllers = [NSArray arrayWithObject:messageViewController];
    
    [self.pageController setViewControllers:viewControllers
                                  direction:UIPageViewControllerNavigationDirectionReverse
                                   animated:YES
                                 completion:nil];
}

- (void) goToComposeViewControllerFromLeft {
    SPComposeViewController *composeViewController = [self.viewControllerArray objectAtIndex:1];
    
    NSArray *viewControllers = [NSArray arrayWithObject:composeViewController];
    _scrollView.bounces = NO;
    [self.pageController setViewControllers:viewControllers
                                  direction:UIPageViewControllerNavigationDirectionForward
                                   animated:YES
                                 completion:nil];
}

- (void) goToComposeViewControllerFromRight {
    SPComposeViewController *composeViewController = [self.viewControllerArray objectAtIndex:1];
    
    NSArray *viewControllers = [NSArray arrayWithObject:composeViewController];
    _scrollView.bounces = NO;
    [self.pageController setViewControllers:viewControllers
                                  direction:UIPageViewControllerNavigationDirectionReverse
                                   animated:YES
                                 completion:nil];
}

- (void) goToFriendsViewController {
    SPFriendsViewController *friendsViewController = [self.viewControllerArray objectAtIndex:2];
    
    NSArray *viewControllers = [NSArray arrayWithObject:friendsViewController];
    _scrollView.bounces = NO;
    [self.pageController setViewControllers:viewControllers
                                  direction:UIPageViewControllerNavigationDirectionForward
                                   animated:YES
                                 completion:nil];
}




@end
