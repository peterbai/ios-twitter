//
//  TimelineTweetCell.h
//  Twitter
//
//  Created by Peter Bai on 2/17/15.
//  Copyright (c) 2015 Peter Bai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tweet.h"

@class TimelineTweetCell;

@protocol TimelineTweetCellDelegate <NSObject>

- (void)replyInvokedFromTimelineTweetCell:(TimelineTweetCell *)timelineTweetCell;
- (void)retweetInvokedFromTimelineTweetCell:(TimelineTweetCell *)timelineTweetCell;
- (void)removeRetweetInvokedFromTimelineTweetCell:(TimelineTweetCell *)timelineTweetCell;
- (void)favoriteInvokedFromTimelineTweetCell:(TimelineTweetCell *)timelineTweetCell;
- (void)removeFavoriteInvokedFromTimelineTweetCell:(TimelineTweetCell *)timelineTweetCell;

@end

@interface TimelineTweetCell : UITableViewCell

@property (nonatomic, strong) Tweet *tweet;
@property (nonatomic, strong) id<TimelineTweetCellDelegate> delegate;

@end
