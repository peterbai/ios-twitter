//
//  DetailTweetCellContent.m
//  Twitter
//
//  Created by Peter Bai on 2/22/15.
//  Copyright (c) 2015 Peter Bai. All rights reserved.
//

#import "DetailTweetCellContent.h"
#import <UIImageView+AFNetworking.h>

@interface DetailTweetCellContent ()

@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *screenname;
@property (weak, nonatomic) IBOutlet UILabel *time;
@property (weak, nonatomic) IBOutlet UILabel *text;

@property (weak, nonatomic) IBOutlet UILabel *retweetedUserLabel;

@end

@implementation DetailTweetCellContent

- (void)awakeFromNib {
    // Initialization code
    self.text.preferredMaxLayoutWidth = self.text.frame.size.width;
    self.profileImageView.image = nil;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.text.preferredMaxLayoutWidth = self.text.frame.size.width;
}


#pragma mark Custom setters

- (void)setTweet:(Tweet *)tweet {
    _tweet = tweet;
    
    if (self.tweet.retweetedTweet) {
        self.retweetedUserLabel.text = [tweet.user.name stringByAppendingString:@" retweeted"];
        
        self.name.text = tweet.retweetedTweet.user.name;
        self.screenname.text = [NSString stringWithFormat:@"@%@", tweet.retweetedTweet.user.screenname];
        self.text.text = tweet.retweetedTweet.text;

        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"M/d/y, h:mm a";
        self.time.text = [dateFormatter stringFromDate:self.tweet.retweetedTweet.createdAt];
        
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
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"M/d/y, h:mm a";
        self.time.text = [dateFormatter stringFromDate:self.tweet.createdAt];
        
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


@end
