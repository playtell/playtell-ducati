//
//  PTChatHUDView2.m
//  playtell-ducati
//
//  Created by Ricky Hussmann on 9/24/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import "PTChatHUDView2.h"

#import "UIView+PlayTell.h"
#import "UIColor+ColorFromHex.h"

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
        
        // Set shadow to the parent layer
        self.backgroundColor = [UIColor clearColor];
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds
                                                       byRoundingCorners:(UIRectCornerBottomLeft|UIRectCornerBottomRight)
                                                             cornerRadii:CGSizeMake(12.0f, 12.0f)];
        
        // Create the shadow layer
        CAShapeLayer *shadowLayer = [CAShapeLayer layer];
        [shadowLayer setFrame:self.bounds];
        [shadowLayer setMasksToBounds:NO];
        [shadowLayer setShadowPath:maskPath.CGPath];
        shadowLayer.shadowColor = [UIColor blackColor].CGColor;
        shadowLayer.shadowOffset = CGSizeMake(0.0f, 0.0f);
        shadowLayer.shadowOpacity = 0.5f;
        shadowLayer.shadowRadius = 6.0f;
        
        CALayer *roundedLayer = [CALayer layer];
        [roundedLayer setFrame:self.bounds];
        [roundedLayer setBackgroundColor:[UIColor colorFromHex:@"#e4ecef"].CGColor];

        [self.layer insertSublayer:shadowLayer atIndex:0];
        
        // Add inner view (since we're rounding corners, parent view can't mask to bounds b/c of shadow - need extra view)
        CAShapeLayer *maskLayer = [CAShapeLayer layer];
        maskLayer.frame = self.bounds;
        maskLayer.path = maskPath.CGPath;
        innerView = [[UIView alloc] initWithFrame:self.bounds];
        innerView.backgroundColor = [UIColor whiteColor];
        innerView.layer.mask = maskLayer;
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
//    // Set new view's frame
//    aView.frame = [[self class] rectForLeftSubview];
//    
//    // Fadeout current subviews
//    [UIView animateWithDuration:0.3f
//                     animations:^{
//                         for (UIView *childView in self.leftContainerView.subviews) {
//                             childView.alpha = 0.0f;
//                         }
//                     }
//                     completion:^(BOOL finished) {
//                         // Remove all children
//                         [self.leftContainerView removeAllSubviews];
//                         
//                         // Add new view
//                         aView.alpha = 0.0f;
//                         [self.leftContainerView addSubview:aView];
//                         [UIView animateWithDuration:0.3f
//                                          animations:^{
//                                              aView.alpha = 1.0f;
//                                          }];
//                     }];
}

- (void)setRightView:(UIView*)aView {
    // Remove OpenTok gestures
    [aView removeAllGestureRecognizers];

    // Set new view's frame
    aView.frame = [[self class] rectForRightSubview];
    
    // Fadeout current subviews
    [UIView animateWithDuration:0.3f
                     animations:^{
                         for (UIView *childView in self.rightContainerView.subviews) {
                             childView.alpha = 0.0f;
                         }
                     }
                     completion:^(BOOL finished) {
                         // Remove all children
                         [self.rightContainerView removeAllSubviews];

                         // Add new view
                         aView.alpha = 0.0f;
                         [self.rightContainerView addSubview:aView];
                         [UIView animateWithDuration:0.3f
                                          animations:^{
                                              aView.alpha = 1.0f;
                                          }];
                     }];
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
