//
//  ComposeViewController.h
//  Twitter
//
//  Created by Peter Bai on 2/21/15.
//  Copyright (c) 2015 Peter Bai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"
#import "Tweet.h"

@class ComposeViewController;

@protocol ComposeViewControllerDelegate <NSObject>

- (void)composeViewController:(ComposeViewController *)composeViewController didSuccessfullyComposeTweet:(Tweet *)tweet;

@end

@interface ComposeViewController : UIViewController

@property (strong, nonatomic) User *user;
@property (strong, nonatomic) Tweet *inReplyToTweet;
@property (strong, nonatomic) id<ComposeViewControllerDelegate> delegate;

@end
