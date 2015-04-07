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

@interface SPContainerViewController ()

@property UIScrollView *scrollView;
@property NSInteger currentPageIndex;

@end

@implementation SPContainerViewController

- (void)viewDidLoad {    
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor redColor]];
    
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

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self resignFirstResponder];
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
//    if (self.currentPageIndex == 0 && _scrollView.contentOffset.x <= _scrollView.bounds.size.width) {
//        velocity = CGPointZero;
//        *targetContentOffset = CGPointMake(scrollView.bounds.size.width, 0);
//    }
//    if (self.currentPageIndex == [self.viewControllerArray count]-1 && scrollView.contentOffset.x >= scrollView.bounds.size.width) {
//        velocity = CGPointZero;
//        *targetContentOffset = CGPointMake(_scrollView.bounds.size.width, 0);
//    }
}


@end
