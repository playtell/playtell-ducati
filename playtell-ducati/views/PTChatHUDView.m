//
//  PTChatHUDView.m
//  PlayTell
//
//  Created by Ricky Hussmann on 5/3/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import "PTChatHUDView.h"

#import "UIColor+ColorFromHex.h"
#import "UIView+PlayTell.h"

#import <QuartzCore/QuartzCore.h>

#define PTCHATVIEW_SUBVIEW_MARGIN 0

@interface PTChatHUDView ()

@property (nonatomic, strong) UIView *innerView;
@property (nonatomic, strong) CAShapeLayer *maskLayer;
@property (nonatomic, strong) CAShapeLayer *shadowLayer;
@property (nonatomic, strong) CALayer *roundedLayer;
@property (nonatomic, strong) UIView *leftContainerView;
@property (nonatomic, strong) UIView *rightContainerView;

@end

@implementation PTChatHUDView
@synthesize innerView;
@synthesize maskLayer;
@synthesize shadowLayer;
@synthesize roundedLayer;
@synthesize leftContainerView;
@synthesize rightContainerView;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.autoresizesSubviews = YES;
        
        float width = frame.size.width;
        float height = frame.size.height;
        
        self.leftContainerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, (width - PTCHATVIEW_SUBVIEW_MARGIN) / 2, height)];
        self.leftContainerView.autoresizesSubviews = YES;
        self.leftContainerView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin;
        
        self.rightContainerView = [[UIView alloc] initWithFrame:CGRectMake((width - self.leftContainerView.frame.size.width), 0.0f, leftContainerView.frame.size.width, height)];
        self.rightContainerView.autoresizesSubviews = YES;
        self.rightContainerView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin;
        
        // Set shadow to the parent layer
        self.backgroundColor = [UIColor clearColor];
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds
                                                       byRoundingCorners:(UIRectCornerBottomLeft|UIRectCornerBottomRight)
                                                             cornerRadii:CGSizeMake(12.0f, 12.0f)];
        
        // Create the shadow layer
        shadowLayer = [CAShapeLayer layer];
        [shadowLayer setFrame:self.bounds];
        [shadowLayer setMasksToBounds:NO];
        [shadowLayer setShadowPath:maskPath.CGPath];
        shadowLayer.shadowColor = [UIColor blackColor].CGColor;
        shadowLayer.shadowOffset = CGSizeMake(0.0f, 0.0f);
        shadowLayer.shadowOpacity = 0.5f;
        shadowLayer.shadowRadius = 6.0f;
        
        roundedLayer = [CALayer layer];
        [roundedLayer setFrame:self.bounds];
        [roundedLayer setBackgroundColor:[UIColor colorFromHex:@"#e4ecef"].CGColor];
        
        [self.layer insertSublayer:shadowLayer atIndex:0];
        
        // Add inner view (since we're rounding corners, parent view can't mask to bounds b/c of shadow - need extra view)
        maskLayer = [CAShapeLayer layer];
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

- (void)layoutSubviews {
    [super layoutSubviews];
    
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds
                                                   byRoundingCorners:(UIRectCornerBottomLeft|UIRectCornerBottomRight)
                                                         cornerRadii:CGSizeMake(12.0f, 12.0f)];
    
    shadowLayer.frame = self.bounds;
    [shadowLayer setShadowPath:maskPath.CGPath];
    
    maskLayer.frame = self.bounds;
    maskLayer.path = maskPath.CGPath;
    
    innerView.frame = self.bounds;
    innerView.layer.mask = maskLayer;
}

- (void)setLoadingImageForLeftView:(UIImage*)anImage loadingText:(NSString*)text {
    UIImageView* anImageview = [[UIImageView alloc] initWithImage:anImage];
    anImageview.contentMode = UIViewContentModeScaleAspectFit;
    [self setLeftView:anImageview];
}

- (void)setLoadingImageForRightView:(UIImage*)anImage {
    UIImageView* anImageview = [[UIImageView alloc] initWithImage:anImage];
    anImageview.contentMode = UIViewContentModeScaleAspectFit;
    [self setRightView:anImageview];
}

- (void)setLeftView:(UIView*)aView {
    [aView removeAllGestureRecognizers];
    
    [self.leftContainerView removeAllSubviews];
    aView.frame = self.leftContainerView.bounds;
    aView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.leftContainerView addSubview:aView];
}

- (void)setRightView:(UIView*)aView {
    // Remove OpenTok gestures
    [aView removeAllGestureRecognizers];
    
    // Set new view's frame
    aView.frame = self.rightContainerView.bounds;
    aView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
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

@end
