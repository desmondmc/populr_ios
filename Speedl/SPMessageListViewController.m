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

#define kMeanMessageArray @[@"GET MORE FRIENDS", @"MAYBE IT'S YOUR FACE", @"HAVE YOU TRIED CROSSFIT?", @"DO BETTER"]

@interface SPMessageListViewController ()

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (strong, nonatomic) IBOutlet UILabel *upperNoResultsLabel;
@property (strong, nonatomic) IBOutlet UILabel *lowerNoResultsLabel;
@property (strong, nonatomic) IBOutlet UIView *noResultsView;

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
    
    _upperNoResultsLabel.text = @"YOU HAVE NO MESSAGES";
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
    SPMessageViewController *messageViewController = [[SPMessageViewController alloc] initWithMessage:messageAtIndex];
    [self removeMessageFromArray:messageAtIndex];
    [self presentViewController: messageViewController animated:NO completion:^{
        [cell.activityIndicator setHidden:YES];
        [cell.messageNumberLabel setHidden:NO];
        [messageAtIndex markMessageAsReadInBackground:^(BOOL success, NSString *serverMessage) {
            [self reloadMessagesData];
        }];
    }];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 90;
}

- (void) newVisableViewController:(UIViewController *)viewController {
    if (viewController == self) {
        [self displayMessagesIfThereAreAny];
    }
}



@end
