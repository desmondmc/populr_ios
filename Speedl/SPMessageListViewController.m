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

@interface SPMessageListViewController ()

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) NSArray *messages;
@property (strong, nonatomic) UIRefreshControl *refreshControl;

@end

@implementation SPMessageListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.tableView registerNib:[UINib nibWithNibName:@"SPMessageTableViewCell" bundle:nil] forCellReuseIdentifier:@"spMessageTableViewCell"];
    
    [self setupAppearance];
    
    [self reloadMessagesData];
}

- (void) reloadMessagesData {
    [[SPUser currentUser] getMessagesInBackground:^(NSArray *messages, NSString *serverMessage) {
        [_tableView setHidden:NO];
        [_activityIndicator setHidden:YES];
        NSLog(@"Got messages");
        _messages = messages;
        [self.tableView reloadData];
        [_refreshControl endRefreshing];
    }];
}

- (void) setupAppearance {
    self.view.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundColor = [UIColor clearColor];
    
    //Add pull to refresh
    _refreshControl = [[UIRefreshControl alloc] init];
    _refreshControl.backgroundColor = [UIColor clearColor];
    _refreshControl.tintColor = [UIColor whiteColor];;
    [_refreshControl addTarget:self action:@selector(reloadMessagesData) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:_refreshControl];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (!_messages) {
        return 0;
    }
    return [_messages count];
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
    NSString *timeLabel = [NSString stringWithFormat: @"%ld mins ago", (long)numberInteger*10];
    
    cell.messageNumberLabel.text = numberLabel;
    cell.messageTimeLabel.text = timeLabel;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
     SPMessageTableViewCell *cell = (SPMessageTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    
    [cell.activityIndicator setHidden:NO];
    [cell.messageNumberLabel setHidden:YES];
    
    SPMessage *messageAtIndex = _messages[indexPath.row];
    SPMessageViewController *messageViewController = [[SPMessageViewController alloc] initWithMessage:messageAtIndex];
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



@end
