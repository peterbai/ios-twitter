//
//  TwitterClient.m
//  Twitter
//
//  Created by Peter Bai on 2/16/15.
//  Copyright (c) 2015 Peter Bai. All rights reserved.
//

#import "TwitterClient.h"
#import "Tweet.h"

NSString * const kTwitterConsumerKey = @"0DyqdQeh7J6MlIOFBC4i68VLQ";
NSString * const kTwitterConsumerSecret = @"DvKf0LCosH9wDf6GeB0UpbtxFVkPGddvXVR9GGNJlATKQOVzoE";
NSString * const kTwitterBaseUrl = @"https://api.twitter.com";

@interface TwitterClient ()

@property (nonatomic, strong) void (^loginCompletion)(User *user, NSError *error);

@end

@implementation TwitterClient

+ (TwitterClient *)sharedInstance {
    static TwitterClient *instance = nil;   // only set once due to `static` declaration
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!instance) {
            instance = [[TwitterClient alloc] initWithBaseURL:[NSURL URLWithString:kTwitterBaseUrl]
                                                  consumerKey:kTwitterConsumerKey
                                               consumerSecret:kTwitterConsumerSecret];
            
        }
    });
    
    return instance;
}

- (void)loginWithCompletion:(void (^)(User *user, NSError *error))completion {
    self.loginCompletion = completion;
    
    [self.requestSerializer removeAccessToken]; // Clear state to avoid reusing saved token
    
    [self
     fetchRequestTokenWithPath:@"oauth/request_token"
     method:@"GET"
     callbackURL:[NSURL URLWithString:@"cptwitterdemo://oauth"]
     scope:nil
     success:^(BDBOAuth1Credential *requestToken) {
         NSLog(@"got the request token");
         NSURL *authURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.twitter.com/oauth/authorize?oauth_token=%@", requestToken.token]];
         [[UIApplication sharedApplication] openURL:authURL];
         
     } failure:^(NSError *error) {
         NSLog(@"Failed to get request token, error: %@", error);
         self.loginCompletion(nil, error);
     }];
}

- (void)openURL:(NSURL *)url {
    [self
     fetchAccessTokenWithPath:@"oauth/access_token"
     method:@"POST"
     requestToken:[[BDBOAuth1Credential alloc] initWithQueryString:url.query]
     success:^(BDBOAuth1Credential *accessToken) {
         NSLog(@"Got the access token");
         [self.requestSerializer saveAccessToken:accessToken];
         
         [self
          GET:@"1.1/account/verify_credentials.json"
          parameters:nil
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              User *user = [[User alloc] initWithDictionary:responseObject];
              [User setcurrentUser:user];
              NSLog(@"current user: %@", user.name);
              self.loginCompletion(user, nil);
              
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSLog(@"Failed getting current user, error: %@", error);
              self.loginCompletion(nil, error);
          }];

     } failure:^(NSError *error) {
         NSLog(@"Failed to get access token, error: %@", error);
     }];
}

- (void)homeTimelineWithParams:(NSDictionary *)params completion:(void (^)(NSArray *tweets, NSError *error))completion {
    [self GET:@"1.1/statuses/home_timeline.json" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@", responseObject);
        
        if ([responseObject isKindOfClass:[NSArray class]]){
            NSArray *tweets = [Tweet tweetsWithArray:responseObject];
            completion(tweets, nil);

        } else {
            NSLog(@"response was not an array: %@", responseObject);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completion(nil, error);
    }];
}

- (void)postTweetWithParams:(NSDictionary *)params completion:(void (^)(id responseObject, NSError *error))completion {
    [self POST:@"1.1/statuses/update.json" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        completion(responseObject, nil);

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completion(nil, error);
    }];
}

- (void)retweetWithParams:(NSDictionary *)params completion:(void (^)(id responseObject, NSError *error))completion {
    NSString *tweetID = params[@"id"];
    
    [self POST:[NSString stringWithFormat:@"1.1/statuses/retweet/%@.json", tweetID] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        completion(responseObject, nil);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completion(nil, error);
    }];
}

- (void)favoriteWithParams:(NSDictionary *)params completion:(void (^)(id responseObject, NSError *error))completion {
    [self POST:@"1.1/favorites/create.json" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        completion(responseObject, nil);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completion(nil, error);
    }];
}

- (void)removeFavoriteWithParams:(NSDictionary *)params completion:(void (^)(id responseObject, NSError *error))completion {
    [self POST:@"1.1/favorites/destroy.json" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        completion(responseObject, nil);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completion(nil, error);
    }];
}

@end
