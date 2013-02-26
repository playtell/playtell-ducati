//
//  PTFullscreenChatView.h
//  playtell-ducati
//
//  Created by Adam Horne on 1/2/13.
//  Copyright (c) 2013 PlayTell. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PTFullscreenChatViewDelegate <NSObject>
@optional
- (void)fullscreenChatViewShouldClose:(UIView *)closingView;
@end

@interface PTFullscreenChatView : UIView <PTFullscreenChatViewDelegate>

@property (nonatomic, strong) id<PTFullscreenChatViewDelegate> delegate;
@property (nonatomic, strong) UIView *subscriberVideoView;
@property (nonatomic, strong) UIView *publisherVideoView;

- (void)setSubscriberImage:(UIImage *)subscriber;
- (void)setPublisherImage:(UIImage *)publisher;

@end