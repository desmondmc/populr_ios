//
//  SPFriendsViewController.m
//  Speedl
//
//  Created by Desmond McNamee on 2015-04-08.
//  Copyright (c) 2015 Speedl. All rights reserved.
//

#import "SPFriendsViewController.h"
#import "SPFriendsTableViewController.h"

@interface SPFriendsViewController ()

@property (strong, nonatomic) IBOutlet UISegmentedControl *segmentControl;
@property (strong, nonatomic) IBOutlet UIView *containerView;

@property (strong, nonatomic) SPFriendsTableViewController *followersTableViewController;
@property (strong, nonatomic) SPFriendsTableViewController *followingTableViewController;

@end

@implementation SPFriendsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupAppearance];
    [self segmentControlDidChange:nil];
}

- (void) setupAppearance {
    [self.segmentControl styleAsMainSpeedlSegmentControl];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)onGoLeftPress:(id)sender {
    [self.containerViewController goToComposeViewControllerFromRight];
}

- (IBAction)segmentControlDidChange:(id)sender {
    switch (_segmentControl.selectedSegmentIndex) {
        case 0: //Following
            [self loadFollowingIntoContainer];
            break;
        case 1: //Followers
            [self loadFollowersIntoContainer];
            break;
        case 2: //Settings
            
            break;
        default:
            break;
    }
}

#pragma mark - Private

- (void)loadFollowingIntoContainer {
    [[_containerView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    SPFriendsTableViewController *followingTableViewController = [self followingTableViewController];
    
    [followingTableViewController willMoveToParentViewController:self];
    [_containerView addSubview:followingTableViewController.view];
    [self addChildViewController:followingTableViewController];
    
    [SPAutoLayout constrainSubviewToFillSuperview:followingTableViewController.view];
    
    [followingTableViewController didMoveToParentViewController:self];
}

- (void)loadFollowersIntoContainer {
    [[_containerView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    SPFriendsTableViewController *followersTableViewController = [self followersTableViewController];
    
    [followersTableViewController willMoveToParentViewController:self];
    [_containerView addSubview:followersTableViewController.view];
    [self addChildViewController:followersTableViewController];
    
    [SPAutoLayout constrainSubviewToFillSuperview:followersTableViewController.view];
    
    [followersTableViewController didMoveToParentViewController:self];
}

- (void)loadSettingsIntoContainer {

}

-(SPFriendsTableViewController *)followersTableViewController {
    if (!_followersTableViewController) {
        _followersTableViewController = [[SPFriendsTableViewController alloc] init];
        _followersTableViewController.numberOfCells = 10;
    }
    return _followersTableViewController;
}

-(SPFriendsTableViewController *)followingTableViewController {
    if (!_followingTableViewController) {
        _followingTableViewController = [[SPFriendsTableViewController alloc] init];
        _followingTableViewController.numberOfCells = 5;
    }
    return _followingTableViewController;
}

#pragma mark - SPContainterViewDelegate

- (void) newVisableViewController:(UIViewController *)viewController {
    if (viewController == self) {
        NSLog(@"FriendsView is visable!!");
    }
}


@end
