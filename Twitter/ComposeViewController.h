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

@interface ComposeViewController : UIViewController

@property (strong, nonatomic) User *user;
@property (nonatomic, strong) Tweet *inReplyToTweet;

@end
