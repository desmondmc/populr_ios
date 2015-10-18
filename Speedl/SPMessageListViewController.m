//
//  SPMessageListViewController.m
//  Speedl
//
//  Created by Desmond McNamee on 2015-04-18.
//  Copyright (c) 2015 Speedl. All rights reserved.
//

#import "SPMessageListViewController.h"
#import "SPMessageTableViewCell.h"
#import "SPMessageViewController.h"

#define kMeanMessageArray @[@"same. waiting on that techcrunch feature", @"send one to that person you like, go on", @"start homing cats", @"go read buzzfeed. No don't",@"we quit our jobs for this", @"give (pops) and you shall receive (pops)", @"it’s not you, it’s them. Really", @"not a single person is thinking about you", @"get more friends", @"maybe it's your face", @"have you tried CrossFit?", @"do better", @"download our other app NotPopulr", @"put your Populr name up on Tinder", @"that's embarassing", @"add your mom", @"cause you smell like dandelions", @"go take the Prius for a wash", @"make a YouTube channel instead", @"enjoy an egg salad", @"your name is Karen, isn't it?", @"pfffft, back to snapchat", @"just wait longer!", @"💩", @"maybe try Ashley Madison", @"join a book club", @"Populr not Populr", @"Ouch."]

@interface SPMessageListViewController ()

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (strong, nonatomic) IBOutlet UILabel *upperNoResultsLabel;
@property (strong, nonatomic) IBOutlet UILabel *lowerNoResultsLabel;
@property (strong, nonatomic) IBOutlet UIView *noResultsView;
@property (strong, nonatomic) IBOutlet UIView *expandingCircle;

@end

@implementation SPMessageListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [_tableView registerNib:[UINib nibWithNibName:@"SPMessageTableViewCell" bundle:nil] forCellReuseIdentifier:@"spMessageTableViewCell"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotMessageCount:) name:kSPMessageCountNotification object:nil];
    
    [self setupAppearance];
    
    [self reloadMessagesData];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)gotMessageCount:(NSNotification *)notification {
    NSLog(@"Got message count! Reloading table.");
    [self displayMessagesIfThereAreAny];
}

- (void)reloadMessagesData {
    [[SPUser currentUser] getMessagesInBackground:^(NSArray *messages, NSString *serverMessage) {
        if ([SPUser getMessageList].count > 0) {
            [self loadedWithMessagesState];
        } else {
            [self loadedNoMessagesState];
        }
        [_tableView reloadData];

        [_refreshControl endRefreshing];
    }];
}

- (void) setupAppearance {
    [_upperNoResultsLabel styleAsFriendCount];
    _upperNoResultsLabel.text = @"No messages";
    _lowerNoResultsLabel.text = [self getMeanMessage];
    self.view.backgroundColor = [SPAppearance getFirstColourForToday];
    _tableView.backgroundColor = [UIColor clearColor];
    
    //Add pull to refresh
    _refreshControl = [[UIRefreshControl alloc] init];
    _refreshControl.backgroundColor = [UIColor clearColor];
    _refreshControl.tintColor = [UIColor whiteColor];;
    [_refreshControl addTarget:self action:@selector(reloadMessagesData) forControlEvents:UIControlEventValueChanged];
    [_tableView addSubview:_refreshControl];
    
    [self displayMessagesIfThereAreAny];
}

- (void)displayMessagesIfThereAreAny {
    if ([SPUser getMessageList].count > 0) {
        [self loadedWithMessagesState];
        [_tableView reloadData];
    } else {
        NSLog(@"No messages :(");
        [self loadedNoMessagesState];
    }
}

- (void)loadedWithMessagesState {
    [_tableView setHidden:NO];
    [_noResultsView setHidden:YES];
}

- (void)loadedNoMessagesState {
    _lowerNoResultsLabel.text = [self getMeanMessage];
    [_noResultsView setHidden:NO];
    [_tableView setHidden:NO];
}

- (NSString *) getMeanMessage {
    int arrayCount = (int)kMeanMessageArray.count;
    NSUInteger randomNumber = arc4random_uniform(arrayCount);
    
    return kMeanMessageArray[randomNumber];
}

// This method removes the message from the local array to ensure that the message is gone by the time the user returns to the message list. It'll later be actually removed.
- (void)removeMessageFromArray:(SPMessage *)message
{
    NSMutableArray *mutableMessages = [[SPUser getMessageList] mutableCopy];
    [mutableMessages removeObject:message];
    [SPUser saveMessageList:mutableMessages];
    [_tableView reloadData];
}

#pragma mark - UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"Cell count: %lu", (unsigned long)[[SPUser getMessageList] count]);
    if (![SPUser getMessageList]) {
        return 0;
    }
    return [[SPUser getMessageList] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"spMessageTableViewCell";
    SPMessageTableViewCell *cell = nil;
    
    cell = (SPMessageTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    if (cell == nil) {
        //There was no reusablecell to dequeue
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"SPMessageTableViewCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    cell.backgroundColor = [UIColor clearColor];
    
    NSInteger numberInteger = indexPath.row + 1;
    NSString *numberLabel = [NSString stringWithFormat: @"%ld", (long)numberInteger];
    
    cell.messageNumberLabel.text = numberLabel;
    
    [cell setupWithMessage:[SPUser getMessageList][indexPath.row]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
     SPMessageTableViewCell *cell = (SPMessageTableViewCell *)[_tableView cellForRowAtIndexPath:indexPath];
    
    [cell.activityIndicator setHidden:NO];
    [cell.messageNumberLabel setHidden:YES];
    
    SPMessage *messageAtIndex = [SPUser getMessageList][indexPath.row];
    SPMessageViewController *messageViewController = [[SPMessageViewController alloc] initWithMessage:messageAtIndex showCountDown:YES];
    [self removeMessageFromArray:messageAtIndex];
    
    CGRect relativeCircleViewFrame = [cell convertRect:cell.circleView.frame toView:self.view];
    CGRectMake(cell.circleView.frame.origin.x, cell.circleView.frame.origin.y, 70.0, 70.0);
    [self.expandingCircle setFrame:relativeCircleViewFrame];
    [self.expandingCircle setHidden:NO];
    [UIView animateWithDuration:0.3 animations:^{
        double sizeMultiplier = 16.0;
        CGRect newRect = CGRectInset(relativeCircleViewFrame, -CGRectGetWidth(relativeCircleViewFrame)*sizeMultiplier/2, -CGRectGetHeight(relativeCircleViewFrame)*sizeMultiplier/2);
        [self.expandingCircle setFrame:newRect];
    } completion:^(BOOL finished) {
        [self presentViewController: messageViewController animated:NO completion:^{
            [cell.activityIndicator setHidden:YES];
            [cell.messageNumberLabel setHidden:NO];
            [self.tableView reloadData];
            [messageAtIndex markMessageAsReadInBackground:^(BOOL success, NSString *serverMessage) {
                [self reloadMessagesData];
            }];
            [self.expandingCircle setHidden:YES];
        }];
    }];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

- (void) newVisableViewController:(UIViewController *)viewController {
    if (viewController == self) {
        [self displayMessagesIfThereAreAny];
    }
}



@end
