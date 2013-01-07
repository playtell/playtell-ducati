//
//  PTFullscreenChatView.m
//  playtell-ducati
//
//  Created by Adam Horne on 1/2/13.
//  Copyright (c) 2013 PlayTell. All rights reserved.
//

#define VIDEO_WIDTH     400.0
#define VIDEO_HEIGHT    300.0

#import "PTFullscreenChatView.h"

#import <QuartzCore/QuartzCore.h>

@implementation PTFullscreenChatView

@synthesize delegate;
@synthesize leftView, rightView;

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
        UISwipeGestureRecognizer *swipeUpRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(userSwipeUpEvent:)];
        swipeUpRecognizer.direction = UISwipeGestureRecognizerDirectionUp;
        [self addGestureRecognizer:swipeUpRecognizer];
        
        // Create the left and right views
        leftView = [[UIView alloc] initWithFrame:self.bounds];
        leftView.alpha = 1.0f;
        leftView.backgroundColor = [UIColor blackColor];
        leftView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self addSubview:leftView];
        rightView = [[UIView alloc] initWithFrame:CGRectMake(800.0f, 594.0f, 200.0f, 150.0f)];
        rightView.alpha = 1.0f;
        rightView.backgroundColor = [UIColor redColor];
        rightView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self addSubview:rightView];
    }
    return self;
}

- (void)userSwipeUpEvent:(UISwipeGestureRecognizer *)recognizer {
    if ([self.delegate respondsToSelector:@selector(fullscreenChatViewShouldClose:)]) {
        [delegate fullscreenChatViewShouldClose:self];
    }
}

@end
