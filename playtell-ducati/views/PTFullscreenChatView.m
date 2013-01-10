//
//  PTFullscreenChatView.m
//  playtell-ducati
//
//  Created by Adam Horne on 1/2/13.
//  Copyright (c) 2013 PlayTell. All rights reserved.
//

#define VIDEO_WIDTH     400.0
#define VIDEO_HEIGHT    300.0
#define CLOSE_MARGIN    10.0

#import "PTFullscreenChatView.h"

#import <QuartzCore/QuartzCore.h>

@interface PTFullscreenChatView()

@property (nonatomic, strong) UIButton *btnClose;
@property (nonatomic, strong) UIImageView *subscriberImageView;
@property (nonatomic, strong) UIImageView *publisherImageView;

@end

@implementation PTFullscreenChatView

@synthesize delegate;
@synthesize subscriberVideoView, publisherVideoView;
@synthesize subscriberImageView, publisherImageView;

@synthesize btnClose;

- (id)init {
    self = [super init];
    if (self) {
        self.autoresizesSubviews = YES;
        self.frame = CGRectMake(0.0f, 0.0f, 1024.0f, 768.0f);
        
        // Create the background
        UIImageView *background = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"photo-bg-dark.png"]];
        background.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self addSubview:background];
        
        // Create the gesture recognizers
//        UISwipeGestureRecognizer *swipeUpRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(userSwipeUpEvent:)];
//        swipeUpRecognizer.direction = UISwipeGestureRecognizerDirectionUp;
//        [self addGestureRecognizer:swipeUpRecognizer];
        
        // Create the subscriber and publisher views
        subscriberVideoView = [[UIView alloc] initWithFrame:self.bounds];
        subscriberVideoView.alpha = 0.0f;
        subscriberVideoView.backgroundColor = [UIColor clearColor];
        subscriberVideoView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self addSubview:subscriberVideoView];
        publisherVideoView = [[UIView alloc] initWithFrame:CGRectMake(800.0f, 594.0f, 200.0f, 150.0f)];
        publisherVideoView.alpha = 0.0f;
        publisherVideoView.backgroundColor = [UIColor clearColor];
        publisherVideoView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self addSubview:publisherVideoView];
        
        // Create the subscriber and publisher image views
        subscriberImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 200.0f, 150.0f)];
        subscriberImageView.center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
        subscriberImageView.backgroundColor = [UIColor clearColor];
        subscriberImageView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self insertSubview:subscriberImageView belowSubview:subscriberVideoView];
        publisherImageView = [[UIImageView alloc] initWithFrame:publisherVideoView.frame];
        publisherImageView.backgroundColor = [UIColor clearColor];
        publisherImageView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self insertSubview:publisherImageView belowSubview:publisherVideoView];
        
        // Create the button to close fullscreen mode
        UIImage *imgClose = [UIImage imageNamed:@"header-close.png"];
        UIImage *imgClosePress = [UIImage imageNamed:@"header-close-press.png"];
        btnClose = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width - imgClose.size.width - CLOSE_MARGIN, CLOSE_MARGIN, imgClose.size.width, imgClose.size.height)];
        [btnClose setBackgroundImage:imgClose forState:UIControlStateNormal];
        [btnClose setBackgroundImage:imgClosePress forState:UIControlStateHighlighted];
        [btnClose addTarget:self action:@selector(closeButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        btnClose.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
        [self addSubview:btnClose];
    }
    return self;
}

- (void)closeButtonPressed {
    if ([self.delegate respondsToSelector:@selector(fullscreenChatViewShouldClose:)]) {
        [delegate fullscreenChatViewShouldClose:self];
    }
}

- (void)userSwipeUpEvent:(UISwipeGestureRecognizer *)recognizer {
    if ([self.delegate respondsToSelector:@selector(fullscreenChatViewShouldClose:)]) {
        [delegate fullscreenChatViewShouldClose:self];
    }
}

- (void)setSubscriberImage:(UIImage *)subscriber {
    subscriberImageView.image = subscriber;
}

- (void)setPublisherImage:(UIImage *)publisher {
    publisherImageView.image = publisher;
}

@end
