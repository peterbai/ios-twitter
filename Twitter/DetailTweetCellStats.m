//
//  DetailTweetCellStats.m
//  Twitter
//
//  Created by Peter Bai on 2/22/15.
//  Copyright (c) 2015 Peter Bai. All rights reserved.
//

#import "DetailTweetCellStats.h"

@interface DetailTweetCellStats ()

@property (weak, nonatomic) IBOutlet UILabel *numberOfRetweetsLabel;
@property (weak, nonatomic) IBOutlet UILabel *numberOfFavoritesLabel;

@end

@implementation DetailTweetCellStats

- (void)awakeFromNib {
    // Initialization code
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark Custom setters

- (void)setTweet:(Tweet *)tweet {
    _tweet = tweet;
    
    if (self.tweet.retweetedTweet) {
        self.numberOfFavoritesLabel.text = [NSString stringWithFormat:@"%@", self.tweet.retweetedTweet.numberOfFavorites];
        self.numberOfRetweetsLabel.text = [NSString stringWithFormat:@"%@", self.tweet.retweetedTweet.numberOfRetweets];
    } else {
        self.numberOfFavoritesLabel.text = [NSString stringWithFormat:@"%@", self.tweet.numberOfFavorites];
        self.numberOfRetweetsLabel.text = [NSString stringWithFormat:@"%@", self.tweet.numberOfRetweets];
    }
}

@end
