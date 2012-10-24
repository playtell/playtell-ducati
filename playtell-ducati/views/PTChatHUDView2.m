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
#define PTCHATVIEW_SUBVIEW_SMALL_WIDTH 200.0
#define PTCHATVIEW_SMALL_HEIGHT 150.0
#define PTCHATVIEW_SUBVIEW_LARGE_WIDTH 400.0
#define PTCHATVIEW_LARGE_HEIGHT 300.0
//#define PTCHATVIEW_WIDTH (2*PTCHATVIEW_SUBVIEW_WIDTH + PTCHATVIEW_SUBVIEW_MARGIN)
//#define PTCHATVIEW_SUBVIEW_HEIGHT PTCHATVIEW_HEIGHT

#define SPINNER_VIEW_TAG 668
#define NAME_VIEW_TAG 669

@interface PTChatHUDView2 ()
@property (nonatomic, strong) UIView *innerView;
@property (nonatomic, strong) CAShapeLayer *maskLayer;
@property (nonatomic, strong) CAShapeLayer *shadowLayer;
@property (nonatomic, strong) CALayer *roundedLayer;
@property (nonatomic, strong) UIView *leftContainerView;
@property (nonatomic, strong) UIView *rightContainerView;
@property (nonatomic, assign) BOOL sizeRestricted;
@end

@implementation PTChatHUDView2
@synthesize innerView;
@synthesize maskLayer;
@synthesize shadowLayer;
@synthesize roundedLayer;
@synthesize leftContainerView;
@synthesize rightContainerView;
@synthesize sizeRestricted;
static float subviewCurrentHeight;
static float subviewCurrentWidth;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        subviewCurrentHeight = PTCHATVIEW_SMALL_HEIGHT;
        subviewCurrentWidth = PTCHATVIEW_SUBVIEW_SMALL_WIDTH;
        self.frame = CGRectMake(512.0-[[self class] chatviewWidth]/2.0, 0, [[self class] chatviewWidth], [[self class] chatviewHeight]);
        self.autoresizesSubviews = YES;
        
        self.leftContainerView = [[UIView alloc] initWithFrame:[[self class] rectForLeftView]];
        self.leftContainerView.autoresizesSubviews = YES;
        self.leftContainerView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin;
        self.rightContainerView = [[UIView alloc] initWithFrame:[[self class] rectForRightView]];
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
        
        // Create the gesture recognizers
        UISwipeGestureRecognizer *swipeDownRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(userSwipeDownEvent:)];
        swipeDownRecognizer.direction = UISwipeGestureRecognizerDirectionDown;
        UISwipeGestureRecognizer *swipeUpRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(userSwipeUpEvent:)];
        swipeUpRecognizer.direction = UISwipeGestureRecognizerDirectionUp;
        UIPinchGestureRecognizer *pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(userPinchEvent:)];
        
        
        // Add the gesture recognizers to the view
        [self addGestureRecognizer:swipeDownRecognizer];
        [self addGestureRecognizer:swipeUpRecognizer];
        [self addGestureRecognizer:pinchRecognizer];
        
        // Restrict the size
        self.sizeRestricted = YES;
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
    aView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
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

- (void)restrictToSmallSize:(BOOL)shouldRestrict {
    if (shouldRestrict && subviewCurrentWidth != PTCHATVIEW_SUBVIEW_SMALL_WIDTH) {
        [self animateSubviewsToWidth:PTCHATVIEW_SUBVIEW_SMALL_WIDTH andHeight:PTCHATVIEW_SMALL_HEIGHT];
    }
    
    self.sizeRestricted = shouldRestrict;
}

- (void)animateSubviewsToWidth:(float)width andHeight:(float)height {
    if (self.sizeRestricted)
        return;
    
    subviewCurrentWidth = width;
    subviewCurrentHeight = height;
    
    [UIView animateWithDuration:0.0f animations:^{
        CGRect newFrame = CGRectMake(512.0-[[self class] chatviewWidth]/2.0, 0, [[self class] chatviewWidth], [[self class] chatviewHeight]);
        self.frame = newFrame;
        
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds
                                                       byRoundingCorners:(UIRectCornerBottomLeft|UIRectCornerBottomRight)
                                                             cornerRadii:CGSizeMake(12.0f, 12.0f)];

        shadowLayer.frame = self.bounds;
        [shadowLayer setShadowPath:maskPath.CGPath];
        
        maskLayer.frame = self.bounds;
        maskLayer.path = maskPath.CGPath;

        innerView.frame = self.bounds;
        innerView.layer.mask = maskLayer;
    //} completion:^(BOOL finished) {
    }];
}

- (void)userSwipeDownEvent:(UISwipeGestureRecognizer *)recognizer {
    if (subviewCurrentWidth != PTCHATVIEW_SUBVIEW_LARGE_WIDTH) {
        [self animateSubviewsToWidth:PTCHATVIEW_SUBVIEW_LARGE_WIDTH andHeight:PTCHATVIEW_LARGE_HEIGHT];
    }
}

- (void)userSwipeUpEvent:(UISwipeGestureRecognizer *)recognizer {
    if (subviewCurrentWidth != PTCHATVIEW_SUBVIEW_SMALL_WIDTH) {
        [self animateSubviewsToWidth:PTCHATVIEW_SUBVIEW_SMALL_WIDTH andHeight:PTCHATVIEW_SMALL_HEIGHT];
    }
}

- (void)userPinchEvent:(UIPinchGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan ||
        recognizer.state == UIGestureRecognizerStateChanged) {
        CGFloat scale = recognizer.scale;
        
        float newWidth = subviewCurrentWidth * scale;
        if (newWidth < PTCHATVIEW_SUBVIEW_SMALL_WIDTH)
            newWidth = PTCHATVIEW_SUBVIEW_SMALL_WIDTH;
        if (newWidth > PTCHATVIEW_SUBVIEW_LARGE_WIDTH)
            newWidth = PTCHATVIEW_SUBVIEW_LARGE_WIDTH;
        
        float newHeight = subviewCurrentHeight * scale;
        if (newHeight < PTCHATVIEW_SMALL_HEIGHT)
            newHeight = PTCHATVIEW_SMALL_HEIGHT;
        if (newHeight > PTCHATVIEW_LARGE_HEIGHT)
            newHeight = PTCHATVIEW_LARGE_HEIGHT;
        
        [self animateSubviewsToWidth:(int)newWidth andHeight:(int)newHeight];
        
        recognizer.scale = 1;
    }
}

+ (float)chatviewHeight {
    return subviewCurrentHeight;
}

+ (float)chatviewWidth {
    return (2*subviewCurrentWidth + PTCHATVIEW_SUBVIEW_MARGIN);
}

+ (CGRect)rectForLeftView {
    return CGRectMake(0,
                      0,
                      (int)subviewCurrentWidth,
                      subviewCurrentHeight);
}

+ (CGRect)rectForRightView {
    return CGRectMake((int)subviewCurrentWidth+PTCHATVIEW_SUBVIEW_MARGIN,
                      0,
                      subviewCurrentWidth,
                      subviewCurrentHeight);
}

+ (CGRect)rectForLeftSubview {
    return [self rectForLeftView];
}

+ (CGRect)rectForRightSubview {
    return [self rectForLeftView];
}

@end
