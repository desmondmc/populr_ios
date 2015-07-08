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
#import "SPMessageListViewController.h"
#import "SPCustomPageControl.h"

@interface SPContainerViewController ()

@property UIScrollView *scrollView;
@property NSInteger currentPageIndex;
@property NSMutableOrderedSet *delegates;
@property (strong, nonatomic) IBOutlet UIView *pageControlContainer;
@property (strong, nonatomic) SPCustomPageControl *customPageControl;

@end

@implementation SPContainerViewController

- (void)viewDidLoad {    
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(goToMessageViewController)
                                                 name:kSPGotoMessageListNotification
                                               object:nil];
    
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
    
    [self setupCustomPageControl];
    
    [self updatePageControl];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.view setBackgroundColor:[SPAppearance globalBackgroundColour]];
}

- (void)setupCustomPageControl {
    [_pageControlContainer addSubview:[self customPageControl]];
    [SPAutoLayout constrainSubviewToFillSuperview:[self customPageControl]];
    [[self view] layoutIfNeeded];
}

-(SPCustomPageControl *)customPageControl {
    if (!_customPageControl) {
        _customPageControl = [SPCustomPageControl viewWithDerivedNibName];
    }
    return _customPageControl;
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
    [self notifyDelegatesOfNewVisableViewController];
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
    
    __weak SPContainerViewController *weakSelf = self;
    
    [self.pageController setViewControllers:viewControllers
                                  direction:UIPageViewControllerNavigationDirectionReverse
                                   animated:YES
                                 completion:^(BOOL finished) {
                                     [weakSelf notifyDelegatesOfNewVisableViewController];
                                 }];
}

- (void) goToComposeViewControllerFromLeft {
    SPComposeViewController *composeViewController = [self.viewControllerArray objectAtIndex:1];
    
    NSArray *viewControllers = [NSArray arrayWithObject:composeViewController];
    _scrollView.bounces = NO;
    
    __weak SPContainerViewController *weakSelf = self;
    
    [self.pageController setViewControllers:viewControllers
                                  direction:UIPageViewControllerNavigationDirectionForward
                                   animated:YES
                                 completion:^(BOOL finished) {
                                     [weakSelf notifyDelegatesOfNewVisableViewController];
                                 }];
}

- (void) goToComposeViewControllerFromRight {
    SPComposeViewController *composeViewController = [self.viewControllerArray objectAtIndex:1];
    
    NSArray *viewControllers = [NSArray arrayWithObject:composeViewController];
    _scrollView.bounces = NO;
    
    __weak SPContainerViewController *weakSelf = self;
    
    [self.pageController setViewControllers:viewControllers
                                  direction:UIPageViewControllerNavigationDirectionReverse
                                   animated:YES
                                 completion:^(BOOL finished) {
                                     [weakSelf notifyDelegatesOfNewVisableViewController];
                                 }];
}

- (void) goToFriendsViewController {
    SPFriendsViewController *friendsViewController = [self.viewControllerArray objectAtIndex:2];
    
    NSArray *viewControllers = [NSArray arrayWithObject:friendsViewController];
    _scrollView.bounces = NO;
    
    __weak SPContainerViewController *weakSelf = self;
    
    [self.pageController setViewControllers:viewControllers
                                  direction:UIPageViewControllerNavigationDirectionForward
                                   animated:YES
                                 completion:^(BOOL finished) {
                                     [weakSelf notifyDelegatesOfNewVisableViewController];
                                 }];
}

- (void) addDelegate:(id <SPContainerViewControllerDelegate>)delegate {
    if (self.delegates == nil) {
        self.delegates = [[NSMutableOrderedSet alloc] init];
    }
    
    [self.delegates addObject:delegate];
}
- (void) removeDelegate:(id <SPContainerViewControllerDelegate>)delegate {
    if (self.delegates == nil) {
        return;
    }
    
    [self.delegates removeObject:delegate];

}

- (void) notifyDelegatesOfNewVisableViewController {
    [self updatePageControl];
    
    for (id <SPContainerViewControllerDelegate> delegate in self.delegates) {
        if ([delegate respondsToSelector:@selector(newVisableViewController:)]) {
            [delegate newVisableViewController:self.pageController.viewControllers[0]];
        }
    }
}

- (void) updatePageControl {
    UIViewController *currentView = self.pageController.viewControllers[0];
    
    if ([currentView isKindOfClass:[SPMessageListViewController class]]) {
        //First View
        [_customPageControl colourCircleAtIndex:0];
    }
    else if([currentView isKindOfClass:[SPComposeViewController class]]){
        //Second View
        [_customPageControl colourCircleAtIndex:1];
    }
    else if([currentView isKindOfClass:[SPFriendsViewController class]]){
        //Third View
        [_customPageControl colourCircleAtIndex:2];
    }
}




@end
