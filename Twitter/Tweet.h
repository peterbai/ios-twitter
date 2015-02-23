//
//  Tweet.h
//  Twitter
//
//  Created by Peter Bai on 2/16/15.
//  Copyright (c) 2015 Peter Bai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

@interface Tweet : NSObject

@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSDate *createdAt;
@property (nonatomic, strong) Tweet *retweetedTweet;
@property (nonatomic, strong) User *user;
@property (nonatomic, strong) NSString *tweetIDString;
@property (nonatomic, strong) NSNumber *numberOfFavorites;
@property (nonatomic, strong) NSNumber *numberOfRetweets;
@property (nonatomic) BOOL favorited;

- (id)initWithDictionary:(NSDictionary *)dictionary;
- (void)updateFavoritedToValue:(BOOL)favorited;

+ (NSArray *)tweetsWithArray:(NSArray *)array;

@end
