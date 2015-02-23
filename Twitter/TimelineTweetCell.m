//
//  TimelineTweetCell.m
//  Twitter
//
//  Created by Peter Bai on 2/17/15.
//  Copyright (c) 2015 Peter Bai. All rights reserved.
//

#import "TimelineTweetCell.h"
#import <UIImageView+AFNetworking.h>
#import <NSDate+DateTools.h>

@interface TimelineTweetCell ()

@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *screenname;
@property (weak, nonatomic) IBOutlet UILabel *time;
@property (weak, nonatomic) IBOutlet UILabel *text;

@property (weak, nonatomic) IBOutlet UIButton *replyButton;
@property (weak, nonatomic) IBOutlet UIButton *retweetButton;
@property (weak, nonatomic) IBOutlet UIButton *starButton;

@property (weak, nonatomic) IBOutlet UILabel *retweetedUserLabel;

@end

@implementation TimelineTweetCell

- (void)awakeFromNib {
    // Initialization code
    self.text.preferredMaxLayoutWidth = self.text.frame.size.width;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.text.preferredMaxLayoutWidth = self.text.frame.size.width;
    
    self.retweetButton.enabled = YES;
    
    if ([self.tweet.user.userID isEqualToNumber:[User currentUser].userID] &&
        !self.tweet.retweeted) {
        self.retweetButton.enabled = NO;
    }
    
    if (self.tweet.favorited) {
        UIImage *btnImage = [UIImage imageNamed:@"Star"];
        [self.starButton setImage:btnImage forState:UIControlStateNormal];
        
    } else {
        UIImage *btnImage = [UIImage imageNamed:@"StarUnselected"];
        [self.starButton setImage:btnImage forState:UIControlStateNormal];
    }
    
    if (self.tweet.retweeted) {
        UIImage *btnImage = [UIImage imageNamed:@"RetweetTrue"];
        [self.retweetButton setImage:btnImage forState:UIControlStateNormal];
        
    } else {
        UIImage *btnImage = [UIImage imageNamed:@"Retweet"];
        [self.retweetButton setImage:btnImage forState:UIControlStateNormal];
    }
}

- (void)prepareForReuse {
    self.profileImageView.image = nil;
}

#pragma mark Custom setters

- (void)setTweet:(Tweet *)tweet {
    _tweet = tweet;
    
    if (self.tweet.retweetedTweet) {
        self.retweetedUserLabel.text = [tweet.user.name stringByAppendingString:@" retweeted"];
        
        self.name.text = tweet.retweetedTweet.user.name;
        self.screenname.text = [NSString stringWithFormat:@"@%@", tweet.retweetedTweet.user.screenname];
        self.text.text = tweet.retweetedTweet.text;
        self.time.text = tweet.retweetedTweet.createdAt.shortTimeAgoSinceNow;
        
        NSURLRequest *imageRequest = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:tweet.retweetedTweet.user.profileImageUrlBigger]];
        [self.profileImageView setImageWithURLRequest:imageRequest placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
            [UIView transitionWithView:self.profileImageView
                              duration:0.3
                               options:UIViewAnimationOptionTransitionCrossDissolve
                            animations:^{
                                self.profileImageView.image = image;
                            } completion: nil];

        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
            NSLog(@"Failed to retrieve profile image: %@", error);
        }];
        
    } else {
        self.name.text = tweet.user.name;
        self.screenname.text = [NSString stringWithFormat:@"@%@", tweet.user.screenname];
        self.text.text = tweet.text;
        self.time.text = tweet.createdAt.shortTimeAgoSinceNow;
        
        NSURLRequest *imageRequest = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:tweet.user.profileImageUrlBigger]];
        [self.profileImageView setImageWithURLRequest:imageRequest placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
            [UIView transitionWithView:self.profileImageView
                              duration:0.3
                               options:UIViewAnimationOptionTransitionCrossDissolve
                            animations:^{
                                self.profileImageView.image = image;
                            } completion: nil];
            
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
            NSLog(@"Failed to retrieve profile image: %@", error);
        }];
    }
}

#pragma mark actions

- (IBAction)onReply:(id)sender {
    [self.delegate replyInvokedFromTimelineTweetCell:self];
}

- (IBAction)onRetweet:(id)sender {
    [self toggleRetweet];
}

- (IBAction)onFavorite:(id)sender {
    [self toggleFavorite];
}

#pragma mark private methods

- (void)toggleRetweet {
    if (self.tweet.retweeted) {
        [self.tweet updateRetweetedToValue:NO];
        [self.delegate removeRetweetInvokedFromTimelineTweetCell:self];
        
        UIImage *btnImage = [UIImage imageNamed:@"Retweet"];
        [self.retweetButton setImage:btnImage forState:UIControlStateNormal];
        
    } else {
        [self.tweet updateRetweetedToValue:YES];
        [self.delegate retweetInvokedFromTimelineTweetCell:self];
        
        UIImage *btnImage = [UIImage imageNamed:@"RetweetTrue"];
        [self.retweetButton setImage:btnImage forState:UIControlStateNormal];
    }
}

- (void)toggleFavorite {
    if (self.tweet.favorited) {
        [self.tweet updateFavoritedToValue:NO];
        
        UIImage *btnImage = [UIImage imageNamed:@"StarUnselected"];
        [self.starButton setImage:btnImage forState:UIControlStateNormal];
        [self.delegate removeFavoriteInvokedFromTimelineTweetCell:self];
        
    } else {
        [self.tweet updateFavoritedToValue:YES];
        
        UIImage *btnImage = [UIImage imageNamed:@"Star"];
        [self.starButton setImage:btnImage forState:UIControlStateNormal];
        [self.delegate favoriteInvokedFromTimelineTweetCell:self];
    }
}

@end
