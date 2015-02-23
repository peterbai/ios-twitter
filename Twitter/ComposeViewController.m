//
//  ComposeViewController.m
//  Twitter
//
//  Created by Peter Bai on 2/21/15.
//  Copyright (c) 2015 Peter Bai. All rights reserved.
//

#import "ComposeViewController.h"
#import <UIImageView+AFNetworking.h>
#import "TwitterClient.h"

@interface ComposeViewController () <UITextViewDelegate, UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UILabel *userLabel;
@property (weak, nonatomic) IBOutlet UILabel *screennameLabel;
@property (weak, nonatomic) IBOutlet UITextView *message;

@end

@implementation ComposeViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Configure navigationBar
    
    self.title = @"Compose";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(onCancel)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Tweet" style:UIBarButtonItemStylePlain target:self action:@selector(onTweet)];
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    [self loadUserDataIntoView];
    [self.message becomeFirstResponder];
    
    // Initialize reply to text
    if (self.inReplyToTweet) {
        NSString *inReplyToUser = [NSString stringWithFormat:@"@%@ ", self.inReplyToTweet.user.screenname];
        self.message.text = inReplyToUser;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UITextViewDelegate methods

- (void)textViewDidChange:(UITextView *)textView {
//    NSLog(@"message: %@", textView.text);
    NSString* textWithoutLinebreaks = [textView.text stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    textView.text = textWithoutLinebreaks;
    
    if (textView.text.length > 0) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    
    } else {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
}

#define MAX_LENGTH 160
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    NSUInteger newLength = (textView.text.length - range.length) + text.length;
    
    if(newLength <= MAX_LENGTH) {
        return YES;
        
    } else {
        NSUInteger emptySpace = MAX_LENGTH - (textView.text.length - range.length);
        textView.text = [[[textView.text substringToIndex:range.location]
                          stringByAppendingString:[text substringToIndex:emptySpace]]
                         stringByAppendingString:[textView.text substringFromIndex:(range.location + range.length)]];
        return NO;
    }
}

#pragma mark UIActionSheetDelegate methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:  // Delete
            [self.message endEditing:YES];
            [self dismissViewControllerAnimated:YES completion:nil];
            break;
        case 1:  // Cancel
            break;
        default:
            break;
    }
}

#pragma mark Private methods

- (void)loadUserDataIntoView {
    self.userLabel.text = self.user.name;
    self.screennameLabel.text = [NSString stringWithFormat:@"@%@", self.user.screenname];
    
    NSURLRequest *profileImageRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:self.user.profileImageUrlBigger]];
    [self.profileImage setImageWithURLRequest:profileImageRequest
                                  placeholderImage:nil
                                           success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                               [UIView transitionWithView:self.profileImage
                                                                 duration:0.3
                                                                  options:UIViewAnimationOptionTransitionCrossDissolve
                                                               animations:^{
                                                                   self.profileImage.image = image;
                                                               } completion: nil];
                                               
                                           } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                               NSLog(@"Error retrieving image: %@", error);
                                           }];
}

- (void)onCancel {
    if (self.message.text.length > 0) {
        UIActionSheet *popup = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete" otherButtonTitles:nil];
        [popup showInView:[UIApplication sharedApplication].keyWindow];
        
    } else {
        [self.message endEditing:YES];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)onTweet {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addEntriesFromDictionary:@{@"status" : self.message.text}];
    
    if (self.inReplyToTweet) {
        [params addEntriesFromDictionary:@{@"in_reply_to_status_id" : self.inReplyToTweet.tweetIDString}];
    }
    
    [[TwitterClient sharedInstance] postTweetWithParams:params completion:^(id responseObject, NSError *error) {
        if (error) {
            NSLog(@"Error posting tweet: %@", error);
            return;
        }

        NSLog(@"posted tweet with response: %@", responseObject);
        [self.message endEditing:YES];
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
}

@end
