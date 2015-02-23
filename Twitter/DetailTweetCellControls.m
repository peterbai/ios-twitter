//
//  DetailTweetCellControls.m
//  Twitter
//
//  Created by Peter Bai on 2/22/15.
//  Copyright (c) 2015 Peter Bai. All rights reserved.
//

#import "DetailTweetCellControls.h"
#import "TweetViewController.h"

@interface DetailTweetCellControls ()

@property (weak, nonatomic) IBOutlet UIButton *retweetButton;
@property (weak, nonatomic) IBOutlet UIButton *favoriteButton;

@end

@implementation DetailTweetCellControls

- (void)awakeFromNib {
    // Initialization code
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if ([self.tweet.user.userID isEqualToNumber:[User currentUser].userID] &&
        !self.tweet.retweeted) {
        self.retweetButton.enabled = NO;
    }
    
    if (self.tweet.favorited) {
        UIImage *btnImage = [UIImage imageNamed:@"DetailStar"];
        [self.favoriteButton setImage:btnImage forState:UIControlStateNormal];
        
    } else {
        UIImage *btnImage = [UIImage imageNamed:@"DetailStarUnselected"];
        [self.favoriteButton setImage:btnImage forState:UIControlStateNormal];
    }
    
    if (self.tweet.retweeted) {
        UIImage *btnImage = [UIImage imageNamed:@"DetailRetweetTrue"];
        [self.retweetButton setImage:btnImage forState:UIControlStateNormal];
        
    } else {
        UIImage *btnImage = [UIImage imageNamed:@"DetailRetweet"];
        [self.retweetButton setImage:btnImage forState:UIControlStateNormal];
    }
}

# pragma mark Actions

- (IBAction)onReply:(id)sender {
    [self.delegate replyInvokedFromDetailTweetCellControls:self];
}
- (IBAction)onRetweet:(id)sender {
    [self toggleRetweet];
}
- (IBAction)onStar:(id)sender {
    [self toggleFavorite];
}

#pragma mark private methods

- (void)toggleRetweet {
    if (self.tweet.retweeted) {
        if (self.tweet.retweetedTweet) {
            [self.tweet.retweetedTweet updateRetweetedToValue:NO];
            [self.tweet updateRetweetedToValue:NO];
        }
        [self.tweet updateRetweetedToValue:NO];
        
        [self.delegate removeRetweetInvokedFromDetailTweetCellControls:self];
        UIImage *btnImage = [UIImage imageNamed:@"DetailRetweet"];
        [self.retweetButton setImage:btnImage forState:UIControlStateNormal];

    } else {
        if (self.tweet.retweetedTweet) {
            [self.tweet.retweetedTweet updateRetweetedToValue:YES];
            [self.tweet updateRetweetedToValue:YES];
        }
        [self.tweet updateRetweetedToValue:YES];
        
        [self.delegate retweetInvokedFromDetailTweetCellControls:self];
        UIImage *btnImage = [UIImage imageNamed:@"DetailRetweetTrue"];
        [self.retweetButton setImage:btnImage forState:UIControlStateNormal];
    }
}

- (void)toggleFavorite {
    if (self.tweet.favorited) {
        
        if (self.tweet.retweetedTweet) {
            [self.tweet.retweetedTweet updateFavoritedToValue:NO];
            [self.tweet updateFavoritedToValue:NO];
        }
        [self.tweet updateFavoritedToValue:NO];
        
        UIImage *btnImage = [UIImage imageNamed:@"DetailStarUnselected"];
        [self.favoriteButton setImage:btnImage forState:UIControlStateNormal];
        [self.delegate removeFavoriteInvokedFromDetailTweetCellControls:self];
        
    } else {
        if (self.tweet.retweetedTweet) {
            [self.tweet.retweetedTweet updateFavoritedToValue:YES];
        }
        [self.tweet updateFavoritedToValue:YES];
        
        UIImage *btnImage = [UIImage imageNamed:@"DetailStar"];
        [self.favoriteButton setImage:btnImage forState:UIControlStateNormal];
        [self.delegate favoriteInvokedFromDetailTweetCellControls:self];
    }
}

@end
