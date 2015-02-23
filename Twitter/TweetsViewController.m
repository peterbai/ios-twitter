//
//  TweetsViewController.m
//  Twitter
//
//  Created by Peter Bai on 2/16/15.
//  Copyright (c) 2015 Peter Bai. All rights reserved.
//

#import "TweetsViewController.h"
#import "User.h"
#import "TwitterClient.h"
#import "Tweet.h"
#import "TimelineTweetCell.h"
#import <SVPullToRefresh.h>
#import "ComposeViewController.h"
#import "TweetViewController.h"

@interface TweetsViewController () <UITableViewDataSource, UITableViewDelegate, TimelineTweetCellDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *tweets;

@end

@implementation TweetsViewController

#pragma mark View methods

- (void)viewDidLoad {
    [super viewDidLoad];

    // Set up tableView
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.estimatedRowHeight = 100;
    self.tableView.rowHeight = UITableViewAutomaticDimension;

    [self.tableView registerNib:[UINib nibWithNibName:@"TimelineTweetCell" bundle:nil] forCellReuseIdentifier:@"TimelineTweetCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"TimelineTweetCellRetweeted" bundle:nil] forCellReuseIdentifier:@"TimelineTweetCellRetweeted"];
    
    // Set up NavigationBar
    self.title = @"Home";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Logout" style:UIBarButtonItemStylePlain target:self action:@selector(onLogout:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"New" style:UIBarButtonItemStylePlain target:self action:@selector(onNew)];
    
    [self getTimelineTweets];
    
}

- (void)viewDidLayoutSubviews {
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
    // attach SVPullToRefresh here so that it detects content inset correctly
    [self.tableView addPullToRefreshWithActionHandler:^{
        [self getTimelineTweets];
    }];
}

#pragma mark Actions

- (IBAction)onLogout:(id)sender {
    [User logout];
}

#pragma mark Table view methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tweets.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TimelineTweetCell *cell;
    if ([(Tweet *)self.tweets[indexPath.row] retweetedTweet]) {
        cell = [self.tableView dequeueReusableCellWithIdentifier:@"TimelineTweetCellRetweeted"];
        
    } else {
        cell = [self.tableView dequeueReusableCellWithIdentifier:@"TimelineTweetCell"];
    }

    cell.tweet = self.tweets[indexPath.row];
    cell.delegate = self;
//    NSLog(@"Tweet with text: %@, has favorite status: %hhd", [(Tweet *)self.tweets[indexPath.row] text],
//          [(Tweet *)self.tweets[indexPath.row] favorited]);
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    TweetViewController *tvc = [[TweetViewController alloc] init];
    tvc.tweet = self.tweets[indexPath.row];
    [self.navigationController pushViewController:tvc animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Remove seperator inset
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    // Prevent the cell from inheriting the Table View's margin settings
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    
    // Explictly set your cell's layout margins
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

// Create separators at top and bottom of tableView
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.5f;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 1)];
    view.backgroundColor = [UIColor lightGrayColor];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.5f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 1)];
    view.backgroundColor = [UIColor lightGrayColor];
    return view;
}

#pragma mark TimelineTweetCellDelegate methods

- (void)replyInvokedFromTimelineTweetCell:(TimelineTweetCell *)timelineTweetCell {
    NSLog(@"replying from timeline!");
    ComposeViewController *cvc = [[ComposeViewController alloc] init];
    cvc.user = [User currentUser];
    cvc.inReplyToTweet = timelineTweetCell.tweet;
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:cvc];
    [self presentViewController:nvc animated:YES completion:nil];
}

- (void)retweetInvokedFromTimelineTweetCell:(TimelineTweetCell *)timelineTweetCell {
    NSLog(@"retweeting from timeline!");
    NSDictionary *params = @{@"id" : timelineTweetCell.tweet.tweetIDString};
    
    [[TwitterClient sharedInstance] retweetWithParams:params completion:^(id responseObject, NSError *error) {
        if (error) {
            NSLog(@"failed to retweet, error: %@", error);
            return;
        }
        NSLog(@"retweeted successfully with response: %@", responseObject);
    }];
}

- (void)favoriteInvokedFromTimelineTweetCell:(TimelineTweetCell *)timelineTweetCell {
    NSLog(@"favoriting from timeline!");
    NSDictionary *params = @{@"id" : timelineTweetCell.tweet.tweetIDString};
    
    [[TwitterClient sharedInstance] favoriteWithParams:params completion:^(id responseObject, NSError *error) {
        if (error) {
            NSLog(@"failed to favorite, error: %@", error);
            return;
        }
        NSLog(@"favorited successfully with response: %@", responseObject);
    }];
}

- (void)removeFavoriteInvokedFromTimelineTweetCell:(TimelineTweetCell *)timelineTweetCell {
    NSLog(@"un-favoriting from timeline!");
    NSDictionary *params = @{@"id" : timelineTweetCell.tweet.tweetIDString};
    
    [[TwitterClient sharedInstance] removeFavoriteWithParams:params completion:^(id responseObject, NSError *error) {
        if (error) {
            NSLog(@"failed to un-favorite, error: %@", error);
            return;
        }
        NSLog(@"un-favorited successfully with response: %@", responseObject);
    }];
}

#pragma mark Twitter API methods

- (void)getTimelineTweets {
    [[TwitterClient sharedInstance] homeTimelineWithParams:nil completion:^(NSArray *tweets, NSError *error) {
        if (error) {
            NSLog(@"Error getting timeline: %@", error);
            return;
        }

        self.tweets = tweets;
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
        [self.tableView.pullToRefreshView stopAnimating];
    }];
}

#pragma mark Private methods

- (void)onNew {
    ComposeViewController *cvc = [[ComposeViewController alloc] init];
    cvc.user = [User currentUser];
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:cvc];

    [self presentViewController:nvc animated:YES completion:nil];
}

#pragma mark System methods

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
