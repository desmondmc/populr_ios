//
//  SPFriendsViewController.m
//  Speedl
//
//  Created by Desmond McNamee on 2015-04-08.
//  Copyright (c) 2015 Speedl. All rights reserved.
//

#import "SPFriendsViewController.h"
#import "SPFriendsTableViewController.h"
#import "SPSearchFriendsViewController.h"
#import "SPSettingsViewController.h"

@interface SPFriendsViewController ()

@property (strong, nonatomic) IBOutlet UISegmentedControl *segmentControl;
@property (strong, nonatomic) IBOutlet UIView *containerView;

@property (strong, nonatomic) SPFriendsTableViewController *followersTableViewController;
@property (strong, nonatomic) SPFriendsTableViewController *followingTableViewController;
@property (strong, nonatomic) SPSearchFriendsViewController *searchTableViewController;
@property (strong, nonatomic) SPSettingsViewController *settingsViewController;
@property (strong, nonatomic) UINavigationController *settingsNavController;
@property (strong, nonatomic) SPCustomTabView *customTabView;
@property (strong, nonatomic) IBOutlet UIView *tabContainerView;


@end

@implementation SPFriendsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupAppearance];
    [self segmentControlDidChange:nil];
    [self addTabView];
}

- (void)addTabView {
    [_tabContainerView addSubview:[self customTabView]];
    [SPAutoLayout constrainSubviewToFillSuperview:[self customTabView]];
}

- (SPCustomTabView *)customTabView {
    if (!_customTabView) {
        _customTabView = [[[NSBundle mainBundle] loadNibNamed:@"SPCustomTabView"
                                                        owner:self
                                                      options:nil] objectAtIndex:0];
        _customTabView.delegate = self;
    }
    return _customTabView;
}

- (void) setupAppearance {
    self.view.backgroundColor = [UIColor clearColor];
    [self.segmentControl styleAsMainSpeedlSegmentControl];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)onGoLeftPress:(id)sender {
    [self.containerViewController goToComposeViewControllerFromRight];
}

- (void)tabSelectedAtIndex:(NSInteger)index {
    switch (index) {
        case 0: //Search
            [self loadSearchIntoContainer];
            break;
        case 1: //Following
            [self loadFollowingIntoContainer];
            break;
        case 2: //Followers
            [self loadFollowersIntoContainer];
            break;
        default:
            break;
    }
}

- (IBAction)segmentControlDidChange:(id)sender {
    switch (_segmentControl.selectedSegmentIndex) {
        case 0: //Search
            [self loadSearchIntoContainer];
            break;
        case 1: //Following
            [self loadFollowingIntoContainer];
            break;
        case 2: //Followers
            [self loadFollowersIntoContainer];
            break;
        default:
            break;
    }
}

#pragma mark - Private

- (void)loadFollowingIntoContainer {
    [[_containerView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    [self addViewIntoContainer:[self followingTableViewController]];
}

- (void)loadFollowersIntoContainer {
    [[_containerView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    [self addViewIntoContainer:[self followersTableViewController]];
}

- (void)loadSearchIntoContainer {
    [[_containerView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    [self addViewIntoContainer:[self searchTableViewController]];
}

- (void)addViewIntoContainer:(UIViewController *)viewController {
    [[_containerView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    [viewController willMoveToParentViewController:self];
    [_containerView addSubview:viewController.view];
    [self addChildViewController:viewController];
    
    [SPAutoLayout constrainSubviewToFillSuperview:viewController.view];
    
    [viewController didMoveToParentViewController:self];
}

-(SPFriendsTableViewController *)followersTableViewController {
    if (!_followersTableViewController) {
        _followersTableViewController = [[SPFriendsTableViewController alloc] init];
        _followersTableViewController.listType = SPFriendListTypeFriends;
    }
    return _followersTableViewController;
}

-(SPFriendsTableViewController *)followingTableViewController {
    if (!_followingTableViewController) {
        _followingTableViewController = [[SPFriendsTableViewController alloc] init];
        _followingTableViewController.listType = SPFriendListTypeFriends;
    }
    return _followingTableViewController;
}

-(SPSearchFriendsViewController *)searchTableViewController {
    if (!_searchTableViewController) {
        _searchTableViewController = [[SPSearchFriendsViewController alloc] init];
    }
    return _searchTableViewController;
}

- (UINavigationController *)settingsNavController {
    if (!_settingsNavController) {
        _settingsNavController = [UINavigationController new];
        _settingsNavController.navigationBarHidden = YES;
        [_settingsNavController addChildViewController:[self settingsViewController]];
    }
    return _settingsNavController;
}

-(SPSettingsViewController *)settingsViewController
{
    if (!_settingsViewController) {
        _settingsViewController = [[SPSettingsViewController alloc] init];
    }
    return _settingsViewController;
}

- (IBAction)didTapSettings:(id)sender {
    [self presentViewController:[self settingsNavController] animated:YES completion:nil];
}
#pragma mark - SPContainterViewDelegate

- (void) newVisableViewController:(UIViewController *)viewController {
    if (viewController == self) {
        [[self customTabView] layoutSubviews];
        NSLog(@"FriendsView is visable!!");
    }
}


@end
