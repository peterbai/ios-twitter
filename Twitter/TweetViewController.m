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

@class TweetViewController;

@protocol TweetViewControllerDelegate <NSObject>

- (void)tweetViewController:(TweetViewController *)tweetViewController didSetFavoriteToValue:(BOOL)value forTweet:(Tweet *)tweet;

@end

@interface TweetViewController () <UITableViewDataSource, UITableViewDelegate, DetailTweetCellControlsDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) id<TweetViewControllerDelegate> delegate;

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
    }];
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

@end
