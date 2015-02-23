//
//  Tweet.m
//  Twitter
//
//  Created by Peter Bai on 2/16/15.
//  Copyright (c) 2015 Peter Bai. All rights reserved.
//

#import "Tweet.h"

@implementation Tweet

- (id)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    
    if (self) {
        self.user = [[User alloc] initWithDictionary:dictionary[@"user"]];
        self.text = dictionary[@"text"];
        self.tweetIDString = dictionary[@"id"];
        self.tweetID = dictionary[@"id"];
        
        NSString *createdAtString = dictionary[@"created_at"];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"EEE MMM d HH:mm:ss Z y";
        self.createdAt = [formatter dateFromString:createdAtString];
        
        self.numberOfFavorites = @([dictionary[@"favorite_count"] intValue]);
        self.numberOfRetweets = @([dictionary[@"retweet_count"] intValue]);
        self.favorited = [dictionary[@"favorited"] boolValue];
        self.retweeted = [dictionary[@"retweeted"] boolValue];
        
        if (dictionary[@"retweeted_status"]) {
            self.retweetedTweet = [[Tweet alloc] initWithDictionary: dictionary[@"retweeted_status"]];
        }
    }

    return self;
}

+ (NSArray *)tweetsWithArray:(NSArray *)array {
    NSMutableArray *tweets = [NSMutableArray array];

    for (NSDictionary *dictionary in array) {
        [tweets addObject:[[Tweet alloc] initWithDictionary:dictionary]];
    }
    
    return tweets;
}

- (void)updateFavoritedToValue:(BOOL)favorited {
    self.favorited = favorited;
    NSLog(@"set tweet favorited to: %hhd", favorited);
    if (favorited) {
        NSNumber *newNumberOfFavorites = [NSNumber numberWithInt:[self.numberOfFavorites intValue] + 1];
        self.numberOfFavorites = newNumberOfFavorites;

    } else if (self.numberOfFavorites.integerValue > 0) {
        NSNumber *newNumberOfFavorites = [NSNumber numberWithInt:[self.numberOfFavorites intValue] - 1];
        self.numberOfFavorites = newNumberOfFavorites;
    }
}

- (void)updateRetweetedToValue:(BOOL)retweeted {
    self.retweeted = retweeted;
    if (retweeted) {
        NSNumber *newNumberOfRetweets = [NSNumber numberWithInt:[self.numberOfRetweets intValue] + 1];
        self.numberOfRetweets = newNumberOfRetweets;

    } else if (self.numberOfRetweets.integerValue > 0) {
        NSNumber *newNumberOfRetweets = [NSNumber numberWithInt:[self.numberOfRetweets intValue] - 1];
        self.numberOfRetweets = newNumberOfRetweets;
    }
}


@end
