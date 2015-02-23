//
//  TwitterClient.h
//  Twitter
//
//  Created by Peter Bai on 2/16/15.
//  Copyright (c) 2015 Peter Bai. All rights reserved.
//

#import "BDBOAuth1RequestOperationManager.h"
#import "User.h"

@interface TwitterClient : BDBOAuth1RequestOperationManager

+ (TwitterClient *)sharedInstance;

- (void)loginWithCompletion:(void (^)(User *user, NSError *error))completion;
- (void)openURL:(NSURL *)url;

- (void)homeTimelineWithParams:(NSDictionary *)params completion:(void (^)(NSArray *tweets, NSError *error))completion;
- (void)postTweetWithParams:(NSDictionary *)params completion:(void (^)(id responseObject, NSError *error))completion;
- (void)retweetWithParams:(NSDictionary *)params completion:(void (^)(id responseObject, NSError *error))completion;
- (void)favoriteWithParams:(NSDictionary *)params completion:(void (^)(id responseObject, NSError *error))completion;
- (void)removeFavoriteWithParams:(NSDictionary *)params completion:(void (^)(id responseObject, NSError *error))completion;

@end
