//
//  DetailTweetCellControls.h
//  Twitter
//
//  Created by Peter Bai on 2/22/15.
//  Copyright (c) 2015 Peter Bai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tweet.h"

@class DetailTweetCellControls;

@protocol DetailTweetCellControlsDelegate <NSObject>

- (void)replyInvokedFromDetailTweetCellControls:(DetailTweetCellControls *)detailCellControls;
- (void)retweetInvokedFromDetailTweetCellControls:(DetailTweetCellControls *)detailCellControls;
- (void)removeRetweetInvokedFromDetailTweetCellControls:(DetailTweetCellControls *)detailCellControls;
- (void)favoriteInvokedFromDetailTweetCellControls:(DetailTweetCellControls *)detailCellControls;
- (void)removeFavoriteInvokedFromDetailTweetCellControls:(DetailTweetCellControls *)detailCellControls;

@end

@interface DetailTweetCellControls : UITableViewCell

@property (nonatomic, strong) id<DetailTweetCellControlsDelegate> delegate;
@property (nonatomic, strong) Tweet *tweet;

@end
