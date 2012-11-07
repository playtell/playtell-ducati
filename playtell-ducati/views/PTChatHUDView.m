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

@property (nonatomic, strong) UIView *innerView;
@property (nonatomic, strong) CAShapeLayer *maskLayer;
@property (nonatomic, strong) CAShapeLayer *shadowLayer;
@property (nonatomic, strong) CALayer *roundedLayer;

@end

@implementation PTChatHUDView
@synthesize innerView;
@synthesize maskLayer;
@synthesize shadowLayer;
@synthesize roundedLayer;
@synthesize containerView;
@synthesize contentView;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.autoresizesSubviews = YES;
        float width = frame.size.width;
        float height = frame.size.height;
        
        // Container
        self.containerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, width, height)];
        self.containerView.backgroundColor = [UIColor whiteColor];
        self.containerView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        
        // Content
        self.contentView = [[UIView alloc] initWithFrame:CGRectMake(CHATVIEW_PADDING, 0.0f, width - (CHATVIEW_PADDING * 2.0f), height - CHATVIEW_PADDING)];
//        NSLog(@"Content frame: %@", NSStringFromCGRect(self.contentView.frame));
        self.contentView.autoresizesSubviews = YES;
        self.contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self.containerView addSubview:self.contentView];
        
        // Set shadow to the parent layer
//        self.backgroundColor = [UIColor redColor];
//        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds
//                                                       byRoundingCorners:(UIRectCornerBottomLeft|UIRectCornerBottomRight)
//                                                             cornerRadii:CGSizeMake(12.0f, 12.0f)];
//        
//        // Create the shadow layer
//        shadowLayer = [CAShapeLayer layer];
//        [shadowLayer setFrame:self.bounds];
//        [shadowLayer setMasksToBounds:NO];
//        [shadowLayer setShadowPath:maskPath.CGPath];
//        shadowLayer.shadowColor = [UIColor blackColor].CGColor;
//        shadowLayer.shadowOffset = CGSizeMake(0.0f, 0.0f);
//        shadowLayer.shadowOpacity = 0.5f;
//        shadowLayer.shadowRadius = 6.0f;
//        
//        roundedLayer = [CALayer layer];
//        [roundedLayer setFrame:self.bounds];
//        [roundedLayer setBackgroundColor:[UIColor colorFromHex:@"#e4ecef"].CGColor];
        
//        [self.layer insertSublayer:shadowLayer atIndex:0];
        
        // Add inner view (since we're rounding corners, parent view can't mask to bounds b/c of shadow - need extra view)
//        maskLayer = [CAShapeLayer layer];
//        maskLayer.frame = self.bounds;
//        maskLayer.path = maskPath.CGPath;
//        innerView = [[UIView alloc] initWithFrame:self.bounds];
//        innerView.backgroundColor = [UIColor whiteColor];
//        innerView.layer.mask = maskLayer;
//        [self addSubview:innerView];
        
        [self addSubview:self.containerView];
    }
    return self;
}

//- (void)setNeedsDisplay {
//    [super setNeedsDisplay];
//    NSLog(@"setNeedsDisplay: %@", NSStringFromCGRect(self.frame));
//}
//
//- (void)setNeedsLayout {
//    [super setNeedsLayout];
//    NSLog(@"setNeedsLayout: %@", NSStringFromCGRect(self.frame));
//}

- (void)layoutSubviews {
    [super layoutSubviews];
    NSLog(@"layoutSubviews: %@", NSStringFromCGRect(self.frame));
    
//    self.leftContainerParentView.frame = CGRectMake(0.0f, 0.0f, ((self.frame.size.width - CHATVIEW_MARGIN) / 2.0f), self.frame.size.height);
//    self.rightContainerParentView.frame = CGRectMake(self.leftContainerParentView.frame.size.width + CHATVIEW_MARGIN, 0.0f, self.leftContainerParentView.frame.size.width, self.frame.size.height);
//    
//    NSLog(@"Container frame: %@", NSStringFromCGRect(self.containerView.frame));
//
//    NSLog(@"Left: %@", NSStringFromCGRect(self.leftContainerView.frame));
//    NSLog(@"Right: %@", NSStringFromCGRect(self.rightContainerView.frame));

//
//    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds
//                                                   byRoundingCorners:(UIRectCornerBottomLeft|UIRectCornerBottomRight)
//                                                         cornerRadii:CGSizeMake(12.0f, 12.0f)];
//    
//    shadowLayer.frame = self.bounds;
//    [shadowLayer setShadowPath:maskPath.CGPath];
//    
//    maskLayer.frame = self.bounds;
//    maskLayer.path = maskPath.CGPath;
//    
//    innerView.frame = self.bounds;
//    innerView.layer.mask = maskLayer;
}

- (void)setLoadingImageForView:(UIImage*)anImage {
    UIImageView* anImageview = [[UIImageView alloc] initWithImage:anImage];
    anImageview.contentMode = UIViewContentModeScaleAspectFit;
    [self setView:anImageview];
}

- (void)setView:(UIView*)aView {
    if ([aView isKindOfClass:[OTVideoView class]]) {
        self.publisherView = (OTVideoView *)aView;
        NSLog(@"------------- setting autoresize mask");
        self.publisherView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
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