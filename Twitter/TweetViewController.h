//
//  TweetViewController.h
//  Twitter
//
//  Created by Peter Bai on 2/22/15.
//  Copyright (c) 2015 Peter Bai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tweet.h"
#import "ComposeViewController.h"

@interface TweetViewController : UIViewController

@property (nonatomic, strong) Tweet *tweet;
@property (strong, nonatomic) id<ComposeViewControllerDelegate> composeViewControllerdelegate;

@end
