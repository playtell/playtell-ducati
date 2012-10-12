//
//  PTChatHUDView2.m
//  playtell-ducati
//
//  Created by Ricky Hussmann on 9/24/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import "PTChatHUDView2.h"

#import "UIView+PlayTell.h"

#import <QuartzCore/QuartzCore.h>

#define PTCHATVIEW_SUBVIEW_MARGIN 0
#define PTCHATVIEW_SUBVIEW_WIDTH 200.0
#define PTCHATVIEW_HEIGHT 150.0
#define PTCHATVIEW_WIDTH (2*PTCHATVIEW_SUBVIEW_WIDTH + PTCHATVIEW_SUBVIEW_MARGIN)
#define PTCHATVIEW_SUBVIEW_HEIGHT PTCHATVIEW_HEIGHT

#define SPINNER_VIEW_TAG 668
#define NAME_VIEW_TAG 669

@interface PTChatHUDView2 ()
@property (nonatomic, strong) UIView *innerView;
@property (nonatomic, strong) UIView *leftContainerView;
@property (nonatomic, strong) UIView *rightContainerView;
@end

@implementation PTChatHUDView2
@synthesize innerView;
@synthesize leftContainerView;
@synthesize rightContainerView;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.frame = CGRectMake(512.0-PTCHATVIEW_WIDTH/2.0, 0, PTCHATVIEW_WIDTH, PTCHATVIEW_HEIGHT);
        
        self.leftContainerView = [[UIView alloc] initWithFrame:[[self class] rectForLeftView]];
        self.rightContainerView = [[UIView alloc] initWithFrame:[[self class] rectForRightView]];
        
        // Setup the inner container views and round the corners
        self.leftContainerView.backgroundColor = [UIColor clearColor];
        self.leftContainerView.layer.cornerRadius = 6.0f;
        self.leftContainerView.clipsToBounds = YES;
        
        self.rightContainerView.backgroundColor = [UIColor clearColor];
        self.rightContainerView.layer.cornerRadius = 6.0f;
        self.rightContainerView.clipsToBounds = YES;
        
        // Set shadow to the parent layer
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shadowOffset = CGSizeMake(0, 0);
        self.layer.shadowOpacity = 0.5;
        self.layer.shadowRadius = 6.0f;
        self.layer.masksToBounds = NO;
        
        // Add inner view (since we're rounding corners, parent view can't mask to bounds b/c of shadow - need extra view)
        innerView = [[UIView alloc] initWithFrame:self.bounds];
        innerView.layer.masksToBounds = YES;
        [self addSubview:innerView];
        
        [innerView addSubview:self.leftContainerView];
        [innerView addSubview:self.rightContainerView];
    }
    return self;
}

- (void)setLoadingImageForLeftView:(UIImage*)anImage loadingText:(NSString*)text {
    UIImageView* anImageview = [[UIImageView alloc] initWithImage:anImage];
    anImageview.contentMode = UIViewContentModeScaleAspectFit;
    [self setLeftView:anImageview];
}

- (void)setLoadingImageForLeftViewWithURL:(NSURL*)aURL loadingText:(NSString*)text {
    [NSException raise:@"PTRemovedMethod"
                format:@"This method has been removed: %@", NSStringFromSelector(_cmd)];
}

- (void)transitionLeftImage {
    [NSException raise:@"PTRemovedMethod"
                format:@"This method has been removed: %@", NSStringFromSelector(_cmd)];
}

- (void)setLoadingImageForRightView:(UIImage*)anImage {
    [self setImageForRightView:anImage];
}

- (void)setImageForRightView:(UIImage*)anImage {
    UIImageView* anImageview = [[UIImageView alloc] initWithImage:anImage];
    anImageview.contentMode = UIViewContentModeScaleAspectFit;
    [self setRightView:anImageview];
}

- (void)setLeftView:(UIView*)aView {
    [aView removeAllGestureRecognizers];
    [self.leftContainerView removeAllSubviews];
    aView.frame = [[self class] rectForLeftSubview];
    [self.leftContainerView addSubview:aView];
}

- (void)setRightView:(UIView*)aView {
    [aView removeAllGestureRecognizers];
    [self.rightContainerView removeAllSubviews];
    aView.frame = [[self class] rectForRightSubview];
    [self.rightContainerView addSubview:aView];
}

+ (CGRect)rectForLeftView {
    return CGRectMake(0,
                      0,
                      (int)PTCHATVIEW_SUBVIEW_WIDTH,
                      PTCHATVIEW_SUBVIEW_HEIGHT);
}

+ (CGRect)rectForRightView {
    return CGRectMake((int)PTCHATVIEW_SUBVIEW_WIDTH+PTCHATVIEW_SUBVIEW_MARGIN,
                      0,
                      PTCHATVIEW_SUBVIEW_WIDTH,
                      PTCHATVIEW_SUBVIEW_HEIGHT);
}

+ (CGRect)rectForLeftSubview {
    return [self rectForLeftView];
}

+ (CGRect)rectForRightSubview {
    return [self rectForLeftView];
}

@end
