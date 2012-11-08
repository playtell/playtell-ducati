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

#define CHATVIEW_PADDING        8.0

@interface PTChatHUDView ()
@end

@implementation PTChatHUDView
@synthesize containerView;
@synthesize contentView;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.autoresizesSubviews = YES;
        float width = frame.size.width;
        float height = frame.size.height;
        
        // Container
        self.containerView = [[UIView alloc] initWithFrame:self.bounds];
        self.containerView.backgroundColor = [UIColor clearColor];
        self.containerView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.containerShadowView = [[UIView alloc] initWithFrame:self.bounds];
        self.containerShadowView.backgroundColor = [UIColor clearColor];
        self.containerShadowView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.containerShadowView.hidden = YES;
        
        // Content
        self.contentView = [[UIView alloc] initWithFrame:CGRectMake(CHATVIEW_PADDING, 0.0f, width - (CHATVIEW_PADDING * 2.0f), height - CHATVIEW_PADDING)];
        self.contentView.autoresizesSubviews = YES;
        self.contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.contentShadowView = [[UIView alloc] initWithFrame:self.contentView.frame];
        self.contentShadowView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self.containerView addSubview:self.contentShadowView];
        [self.containerView addSubview:self.contentView];
        
        // Container shadow setup
        UIBezierPath *containerMaskPath = [UIBezierPath bezierPathWithRoundedRect:self.containerView.bounds
                                                                byRoundingCorners:(UIRectCornerBottomLeft|UIRectCornerBottomRight)
                                                                      cornerRadii:CGSizeMake(16.0f, 16.0f)];
        containerShadowLayer = [CAShapeLayer layer];
        [containerShadowLayer setFrame:self.containerView.bounds];
        [containerShadowLayer setMasksToBounds:NO];
        [containerShadowLayer setShadowPath:containerMaskPath.CGPath];
        containerShadowLayer.shadowColor = [UIColor blackColor].CGColor;
        containerShadowLayer.shadowOffset = CGSizeMake(0.0f, 0.0f);
        containerShadowLayer.shadowOpacity = 0.5f;
        containerShadowLayer.shadowRadius = 5.0f;
        [self.containerShadowView.layer insertSublayer:containerShadowLayer atIndex:0];
        containerMaskLayer = [CAShapeLayer layer];
        containerMaskLayer.frame = self.containerView.bounds;
        containerMaskLayer.path = containerMaskPath.CGPath;
        self.containerView.layer.mask = containerMaskLayer;
        
        // Content shadow setup
        UIBezierPath *contentMaskPath = [UIBezierPath bezierPathWithRoundedRect:self.contentView.bounds
                                                              byRoundingCorners:(UIRectCornerBottomLeft|UIRectCornerBottomRight)
                                                                    cornerRadii:CGSizeMake(12.0f, 12.0f)];
        contentShadowLayer = [CAShapeLayer layer];
        [contentShadowLayer setFrame:self.contentView.bounds];
        [contentShadowLayer setMasksToBounds:NO];
        [contentShadowLayer setShadowPath:contentMaskPath.CGPath];
        contentShadowLayer.shadowColor = [UIColor blackColor].CGColor;
        contentShadowLayer.shadowOffset = CGSizeMake(0.0f, 0.0f);
        contentShadowLayer.shadowOpacity = 0.5f;
        contentShadowLayer.shadowRadius = 4.0f;
        [self.contentShadowView.layer insertSublayer:contentShadowLayer atIndex:0];
        contentMaskLayer = [CAShapeLayer layer];
        contentMaskLayer.frame = self.contentView.bounds;
        contentMaskLayer.path = contentMaskPath.CGPath;
        self.contentView.layer.mask = contentMaskLayer;
        
        // Container views
        [self addSubview:self.containerShadowView];
        [self addSubview:self.containerView];
        
        // Border off by default
        isBorderShown = NO;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    // Redefine container mask
    UIBezierPath *containerMaskPath = [UIBezierPath bezierPathWithRoundedRect:self.containerView.bounds
                                                            byRoundingCorners:(UIRectCornerBottomLeft|UIRectCornerBottomRight)
                                                                  cornerRadii:CGSizeMake(16.0f, 16.0f)];
    containerShadowLayer.shadowPath = containerMaskPath.CGPath;
    containerMaskLayer.frame = self.containerView.bounds;
    containerMaskLayer.path = containerMaskPath.CGPath;
    
    // Redefine content mask
    UIBezierPath *contentMaskPath = [UIBezierPath bezierPathWithRoundedRect:self.contentView.bounds
                                                          byRoundingCorners:(UIRectCornerBottomLeft|UIRectCornerBottomRight)
                                                                cornerRadii:CGSizeMake(12.0f, 12.0f)];
    contentShadowLayer.shadowPath = contentMaskPath.CGPath;
    contentMaskLayer.frame = self.contentView.bounds;
    contentMaskLayer.path = contentMaskPath.CGPath;
}

- (void)setLoadingImageForView:(UIImage*)anImage {
    UIImageView* anImageview = [[UIImageView alloc] initWithImage:anImage];
    anImageview.contentMode = UIViewContentModeScaleAspectFit;
    [self setView:anImageview];
}

- (void)setView:(UIView*)aView {
    if ([aView isKindOfClass:[OTVideoView class]]) {
        self.publisherView = (OTVideoView *)aView;
    } else {
        self.publisherView = nil;
    }
    
    // Remove OpenTok gestures
    [aView removeAllGestureRecognizers];
    
    [self.contentView removeAllSubviews];
    aView.frame = self.contentView.bounds;
    aView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.contentView addSubview:aView];
}

- (void)showBorder {
    if (isBorderShown == YES) {
        return;
    }
    isBorderShown = YES;
    
    // Hide content shadow (to be replaced by border and its own shadow)
    self.contentShadowView.hidden = YES;
    
    // Show container (border) and its own shadow
    self.containerView.backgroundColor = [UIColor whiteColor];
    self.containerShadowView.hidden = NO;
}

- (void)hideBorder {
    if (isBorderShown == NO) {
        return;
    }
    isBorderShown = NO;
    
    // Hide container (border) and its own shadow
    self.containerView.backgroundColor = [UIColor clearColor];
    self.containerShadowView.hidden = YES;

    // Show content shadow (to replace the border and its own shadow)
    self.contentShadowView.hidden = NO;
}

- (void)pulsateBorderWithColor:(UIColor *)color {
    [UIView animateWithDuration:0.3f animations:^{
        self.containerView.backgroundColor = color;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3f animations:^{
            self.containerView.backgroundColor = [UIColor whiteColor];
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.3f animations:^{
                self.containerView.backgroundColor = color;
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.3f animations:^{
                    self.containerView.backgroundColor = [UIColor whiteColor];
                } completion:^(BOOL finished) {
                    [UIView animateWithDuration:0.3f animations:^{
                        self.containerView.backgroundColor = color;
                    } completion:^(BOOL finished) {
                        [UIView animateWithDuration:0.3f animations:^{
                            self.containerView.backgroundColor = [UIColor whiteColor];
                        } completion:^(BOOL finished) {
                            [UIView animateWithDuration:0.3f animations:^{
                                self.containerView.backgroundColor = color;
                            }];
                        }];
                    }];
                }];
            }];
        }];
    }];
}

//- (void)setRightView:(UIView*)aView {
//    if ([aView isKindOfClass:[OTVideoView class]]) {
//        self.publisherView = (OTVideoView *)aView;
//    } else {
//        self.publisherView = nil;
//    }
//    
//    // Remove OpenTok gestures
//    [aView removeAllGestureRecognizers];
//    
//    // Set new view's frame
//    aView.frame = self.rightContainerView.bounds;
//    aView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
//    
//    // Fadeout current subviews
//    [UIView animateWithDuration:0.3f
//                     animations:^{
//                         for (UIView *childView in self.rightContainerView.subviews) {
//                             childView.alpha = 0.0f;
//                         }
//                     }
//                     completion:^(BOOL finished) {
//                         // Remove all children
//                         [self.rightContainerView removeAllSubviews];
//                         
//                         // Add new view
//                         aView.alpha = 0.0f;
//                         [self.rightContainerView addSubview:aView];
//                         [UIView animateWithDuration:0.3f
//                                          animations:^{
//                                              aView.alpha = 1.0f;
//                                          }];
//                     }];
//}

@end