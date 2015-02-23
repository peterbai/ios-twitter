//
//  TweetViewController.m
//  Twitter
//
//  Created by Peter Bai on 2/22/15.
//  Copyright (c) 2015 Peter Bai. All rights reserved.
//

#import "TwitterClient.h"
#import "TweetViewController.h"
#import "DetailTweetCellContent.h"
#import "DetailTweetCellStats.h"
#import "DetailTweetCellControls.h"
#import "ComposeViewController.h"

@interface TweetViewController () <UITableViewDataSource, UITableViewDelegate, DetailTweetCellControlsDelegate, ComposeViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation TweetViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Set up navigation bar
    self.title = @"Tweet";
    
    // Set up tableview
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"DetailTweetCellContent" bundle:nil] forCellReuseIdentifier:@"DetailTweetCellContent"];
    [self.tableView registerNib:[UINib nibWithNibName:@"DetailTweetCellStats" bundle:nil] forCellReuseIdentifier:@"DetailTweetCellStats"];
    [self.tableView registerNib:[UINib nibWithNibName:@"DetailTweetCellControls" bundle:nil] forCellReuseIdentifier:@"DetailTweetCellControls"];
    
    self.tableView.estimatedRowHeight = 100;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
}

- (void)viewWillAppear:(BOOL)animated {
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

# pragma mark UITableView methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        DetailTweetCellContent *cell = [self.tableView dequeueReusableCellWithIdentifier:@"DetailTweetCellContent"];
        cell.tweet = self.tweet;
        return cell;

    } else if (indexPath.row == 1) {
        DetailTweetCellStats *cell = [self.tableView dequeueReusableCellWithIdentifier:@"DetailTweetCellStats"];
        cell.tweet = self.tweet;
        return cell;
        
    } else if (indexPath.row == 2) {
        DetailTweetCellControls *cell = [self.tableView dequeueReusableCellWithIdentifier:@"DetailTweetCellControls"];
        cell.delegate = self;
        cell.tweet = self.tweet;
        return cell;
    }
    
    return [[UITableViewCell alloc] init];
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

#pragma mark DetailTweetCellControlsDelegate methods

- (void)replyInvokedFromDetailTweetCellControls:(DetailTweetCellControls *)detailCellControls {
    NSLog(@"replying!");
    ComposeViewController *cvc = [[ComposeViewController alloc] init];
    cvc.delegate = self.composeViewControllerdelegate;
    cvc.user = [User currentUser];
    cvc.inReplyToTweet = self.tweet;
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:cvc];
    [self presentViewController:nvc animated:YES completion:nil];
}

- (void)retweetInvokedFromDetailTweetCellControls:(DetailTweetCellControls *)detailCellControls {
    NSLog(@"retweeting!");
    NSDictionary *params = @{@"id" : self.tweet.tweetIDString};
    
    [[TwitterClient sharedInstance] retweetWithParams:params completion:^(id responseObject, NSError *error) {
        if (error) {
            NSLog(@"failed to retweet, error: %@", error);
            return;
        }
        
        NSLog(@"retweeted successfully with response: %@", responseObject);
        self.tweet.myNewRetweetedTweet = [[Tweet alloc] initWithDictionary:responseObject];
    }];
    [self.tableView reloadData];
}

- (void)removeRetweetInvokedFromDetailTweetCellControls:(DetailTweetCellControls *)detailCellControls {
    NSLog(@"un-retweeting!");

    NSDictionary *params;
    if (self.tweet.myNewRetweetedTweet) {
        params = @{@"id" : self.tweet.myNewRetweetedTweet.tweetIDString};
        
    } else {
        params = @{@"id" : self.tweet.tweetIDString};
    }
    
    [[TwitterClient sharedInstance] removeRetweetWithParams:params completion:^(id responseObject, NSError *error) {
        if (error) {
            NSLog(@"failed to remove retweet, error: %@", error);
            return;
        }
        NSLog(@"removed retweet successfully with response: %@", responseObject);
    }];
    [self.tableView reloadData];
}

- (void)favoriteInvokedFromDetailTweetCellControls:(DetailTweetCellControls *)detailCellControls {
    NSLog(@"favoriting!");
    NSDictionary *params = @{@"id" : self.tweet.tweetIDString};
    
    [[TwitterClient sharedInstance] favoriteWithParams:params completion:^(id responseObject, NSError *error) {
        if (error) {
            NSLog(@"failed to favorite, error: %@", error);
            return;
        }
        NSLog(@"favorited successfully with response: %@", responseObject);
    }];
    [self.tableView reloadData];
}

- (void)removeFavoriteInvokedFromDetailTweetCellControls:(DetailTweetCellControls *)detailCellControls {
    NSLog(@"un-favoriting!");
    NSDictionary *params = @{@"id" : self.tweet.tweetIDString};
    
    [[TwitterClient sharedInstance] removeFavoriteWithParams:params completion:^(id responseObject, NSError *error) {
        if (error) {
            NSLog(@"failed to un-favorite, error: %@", error);
            return;
        }
        NSLog(@"un-favorited successfully with response: %@", responseObject);
    }];
    [self.tableView reloadData];
}

#pragma mark ComposeViewControllerDelegate methods

- (void)composeViewController:(ComposeViewController *)composeViewController didSuccessfullyComposeTweet:(Tweet *)tweet {
    
}

@end
