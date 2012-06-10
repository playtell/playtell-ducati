//
//  PTChatHUDView.m
//  PlayTell
//
//  Created by Ricky Hussmann on 5/3/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import "PTChatHUDView.h"

#import "UIImageView+PlayTell.h"
#import "UIView+PlayTell.h"

#import <QuartzCore/QuartzCore.h>

#define PTCHATVIEW_SUBVIEW_MARGIN 0
#define PTCHATVIEW_SUBVIEW_WIDTH 200.0
#define PTCHATVIEW_HEIGHT 150.0
#define PTCHATVIEW_WIDTH (2*PTCHATVIEW_SUBVIEW_WIDTH + PTCHATVIEW_SUBVIEW_MARGIN)
#define PTCHATVIEW_SUBVIEW_HEIGHT PTCHATVIEW_HEIGHT

#define SPINNER_VIEW_TAG 668
#define NAME_VIEW_TAG 669

@interface PTChatHUDView ()
+ (CGRect)rectForLeftView;
+ (CGRect)rectForRightView;
+ (UIFont*)nameFont;

- (UIColor*)photoBorderColor;
- (UIView*)createWaitingView;

- (void)setLeftImagePlaceholderWithURL:(NSString*)aURL;
- (void)setRightImagePlaceholderWithURL:(NSString*)aURL;

@property (nonatomic, strong) UIImageView* leftImageView;
@property (nonatomic, strong) UIImageView* rightImageView;
@property (nonatomic, strong) UIView* leftVideoView;
@property (nonatomic, strong) UIView* rightVideoView;

@property (nonatomic, strong) UIView* theLeftView;
@property (nonatomic, strong) UIView* theRightView;

@property (nonatomic, strong) UIView* ghostView;
@property (nonatomic, strong) UILabel* leftUpperLabel;
@property (nonatomic, strong) UILabel* leftLowerLabel;
@property (nonatomic, strong) UIImageView* reconnectedImage;

@property (nonatomic, strong) UIButton* reconnectButton;
@property (nonatomic, copy) PTChatHUDViewReconnectBlock reconnectHandler;
@end

@implementation PTChatHUDView
@synthesize theLeftView, theRightView;
@synthesize leftImageView, rightImageView;
@synthesize leftVideoView, rightVideoView;
@synthesize reconnectButton;
@synthesize reconnectHandler;
@synthesize ghostView;
@synthesize leftUpperLabel, leftLowerLabel;
@synthesize reconnectedImage;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.frame = CGRectMake(512.0-PTCHATVIEW_WIDTH/2.0, 0, PTCHATVIEW_WIDTH, PTCHATVIEW_HEIGHT);

        self.leftImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.rightImageView = [[UIImageView alloc] initWithFrame:CGRectZero];

        self.theLeftView = [[UIView alloc] initWithFrame:[[self class] rectForLeftView]];
        self.theRightView = [[UIView alloc] initWithFrame:[[self class] rectForRightView]];

        self.theLeftView.backgroundColor = [UIColor clearColor];
        self.theLeftView.layer.shadowOffset = CGSizeMake(0, 3);
//        self.theLeftView.layer.shadowOpacity = 0.5;
        self.theRightView.backgroundColor = [UIColor clearColor];
        self.theRightView.layer.shadowOffset = CGSizeMake(0, 3);
        self.theRightView.layer.shadowOpacity = 0.5;

        [self addSubview:self.theLeftView];
        [self addSubview:self.theRightView];
        [self bringSubviewToFront:self.theRightView];
    }
    return self;
}

+ (CGRect)rectForLeftView {
    return CGRectMake(0, 0, (int)PTCHATVIEW_SUBVIEW_WIDTH, PTCHATVIEW_SUBVIEW_HEIGHT);
}

+ (CGRect)rectForRightView {
    return CGRectMake((int)PTCHATVIEW_SUBVIEW_WIDTH+PTCHATVIEW_SUBVIEW_MARGIN, 0, PTCHATVIEW_SUBVIEW_WIDTH, PTCHATVIEW_SUBVIEW_HEIGHT);
}

- (void)setLoadingImageForLeftView:(UIImage*)anImage loadingText:(NSString*)text {
    [self.theLeftView removeFromSuperview];

    CGRect imageViewFrame = [[self class] rectForLeftView];
    imageViewFrame.size.height -= 2.0;
    self.leftImageView.frame = imageViewFrame;
    self.leftImageView.layer.borderColor = [UIColor blackColor].CGColor;
    self.leftImageView.layer.borderWidth = 3.0;

    CGRect ghostFrame = CGRectZero;
    ghostFrame.size = self.leftImageView.frame.size;
    self.ghostView.frame = ghostFrame;
    [self.leftImageView addSubview:self.ghostView];

    UIView* spinningCrank = [self createWaitingView];
    spinningCrank.tag = SPINNER_VIEW_TAG;
    spinningCrank.center = self.leftImageView.center;
    [self.leftImageView addSubview:spinningCrank];

    CGSize maxTextSize = CGSizeMake(PTCHATVIEW_SUBVIEW_WIDTH, PTCHATVIEW_SUBVIEW_HEIGHT/4.0);
    CGSize computedLabelSize = [text sizeWithFont:[[self class] nameFont]
                                constrainedToSize:maxTextSize];

    CGFloat labelOriginX = CGRectGetMidX(self.leftImageView.bounds) - computedLabelSize.width/2.0;
    CGFloat labelOriginY = PTCHATVIEW_SUBVIEW_HEIGHT - computedLabelSize.height - 5.0;
    UILabel* nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(labelOriginX, labelOriginY,
                                                                   computedLabelSize.width, computedLabelSize.height)];
    nameLabel.font = [[self class] nameFont];
    nameLabel.text = text;
    nameLabel.backgroundColor = [UIColor clearColor];
    nameLabel.textColor = [UIColor blackColor];
    nameLabel.tag = NAME_VIEW_TAG;
    [self.leftImageView addSubview:nameLabel];

//    self.theLeftView = self.leftImageView;
    [self.theLeftView addSubview:self.leftImageView];
}


- (UIColor*)loadingBorderColor {
    return [UIColor blackColor];
}

- (void)enableReconnectViewWithClickHandler:(PTChatHUDViewReconnectBlock)handler {
    NSLog(@"Enabling reconnect view");
    self.reconnectHandler = handler;

    CGRect ghostRect = CGRectZero;
    ghostRect.size = self.theLeftView.frame.size;
    self.ghostView.frame = ghostRect;

    [self.theLeftView addSubview:self.ghostView];
    [self.theLeftView addSubviewAndCenter:self.reconnectButton];

    NSString* callLostText =  @"CALL LOST";
    UIFont* callLostFont = [[self class] nameFont];
    CGSize maxLabelSize = CGSizeMake(CGRectGetWidth(self.theLeftView.bounds), CGFLOAT_MAX);
    CGSize callLostTextSize = [callLostText sizeWithFont:callLostFont constrainedToSize:maxLabelSize];
    CGRect callLostFrame = CGRectZero;
    callLostFrame.size = callLostTextSize;
    callLostFrame.origin.x = CGRectGetMidX(self.theLeftView.bounds) - callLostTextSize.width/2.0;
    callLostFrame.origin.y = 10.0;

    self.leftUpperLabel.frame = callLostFrame;
    self.leftUpperLabel.text = callLostText;
    self.leftUpperLabel.font = callLostFont;
    self.leftUpperLabel.backgroundColor = [UIColor clearColor];
    [self.theLeftView addSubview:self.leftUpperLabel];

    NSString* reconnectText = @"RECONNECT";
    UIFont* reconnectFont = [[self class] nameFont];
    CGSize reconnectTextSize = [reconnectText sizeWithFont:reconnectFont constrainedToSize:maxLabelSize];
    CGRect reconnectFrame = CGRectZero;
    reconnectFrame.size = reconnectTextSize;
    reconnectFrame.origin.x = CGRectGetMidX(self.theLeftView.bounds) - reconnectTextSize.width/2.0;
    reconnectFrame.origin.y = CGRectGetMaxY(self.theLeftView.bounds) - reconnectTextSize.height - 5.0;

    self.leftLowerLabel.frame = reconnectFrame;
    self.leftLowerLabel.text = reconnectText;
    self.leftLowerLabel.font = reconnectFont;
    self.leftLowerLabel.backgroundColor = [UIColor clearColor];
    [self.theLeftView addSubview:self.leftLowerLabel];

    self.theLeftView.layer.borderColor = [self loadingBorderColor].CGColor;
    self.theLeftView.layer.borderWidth = 3.0;
}

- (UIButton*)reconnectButton {
    if (!reconnectButton) {
        UIImage* buttonImage = [UIImage imageNamed:@"reconnect.png"];
        UIImage* buttonPressedImage = [UIImage imageNamed:@"reconnect_press.png"];

        UIButton* aButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [aButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
        [aButton setBackgroundImage:buttonPressedImage forState:UIControlStateHighlighted];
        [aButton addTarget:self action:@selector(reconnect:) forControlEvents:UIControlEventTouchUpInside];

        CGRect buttonRect = CGRectZero;
        buttonRect.size = buttonImage.size;
        aButton.frame = buttonRect;
        self.reconnectButton = aButton;
    }

    return reconnectButton;
}

- (UILabel*)leftUpperLabel {
    if (!leftUpperLabel) {
        leftUpperLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    }

    return leftUpperLabel;
}

- (UILabel*)leftLowerLabel {
    if (!leftLowerLabel) {
        leftLowerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    }

    return leftLowerLabel;
}

- (UIImageView*)reconnectedImage {
    if (!reconnectedImage) {
        UIImage* reconnectImage = [UIImage imageNamed:@"reconnecting.png"];
        reconnectedImage = [[UIImageView alloc] initWithImage:reconnectImage];
    }
    return reconnectedImage;
}

- (void)reconnect:(id)sender {
    [self removeReconnectButton];
    [self addLoadingIndicator];

    CGSize maxLabelSize = CGSizeMake(CGRectGetWidth(self.theLeftView.bounds), CGFLOAT_MAX);
    NSString* dialingText = @"DIALING...";
    UIFont* dialingFont = [[self class] nameFont];
    CGSize dialingTextSize = [dialingText sizeWithFont:dialingFont constrainedToSize:maxLabelSize];
    CGRect dialingFrame = CGRectZero;
    dialingFrame.size = dialingTextSize;
    dialingFrame.origin.x = CGRectGetMidX(self.theLeftView.bounds) - dialingTextSize.width/2.0;
    dialingFrame.origin.y = CGRectGetMaxY(self.theLeftView.bounds) - dialingTextSize.height - 5.0;

    self.leftLowerLabel.text = dialingText;
    self.leftLowerLabel.font = dialingFont;
    self.leftLowerLabel.frame = dialingFrame;

    if (self.reconnectHandler) {
        self.reconnectHandler();
    }
}

- (void)addLoadingIndicator {
    UIView* spinningCrank = [self createWaitingView];
    [self.theLeftView addSubviewAndCenter:spinningCrank];
}

- (void)addGhostView {
    CGRect ghostRect = CGRectZero;
    ghostRect.size = self.theLeftView.frame.size;
    self.ghostView.frame = ghostRect;
    [self.theLeftView addSubview:self.ghostView];
}

- (void)removeReconnectButton {
    [self.reconnectButton removeFromSuperview];
    self.reconnectButton = nil;
}

- (UIView*)ghostView {
    if (!ghostView) {
        UIView* aGhostView = [[UIView alloc] initWithFrame:CGRectZero];
        aGhostView.backgroundColor = [UIColor whiteColor];
        aGhostView.alpha = 0.7;
        ghostView = aGhostView;
    }

    return ghostView;
}

- (void)setLoadingImageForLeftViewWithURL:(NSURL*)aURL loadingText:(NSString*)text {

    __block __typeof__(self) blockSelf = self;
    [self.leftImageView setImageWithAURL:aURL
                         origin:CGPointZero
                        maxSize:CGSizeMake(PTCHATVIEW_SUBVIEW_WIDTH, PTCHATVIEW_SUBVIEW_HEIGHT)
                    completeion:^(UIImageView *imageView) {
                        [blockSelf.theLeftView removeFromSuperview];
                        blockSelf.theLeftView.layer.borderColor = [self loadingBorderColor].CGColor;
                        blockSelf.theLeftView.layer.borderWidth = 3.0;

                        UIBezierPath* shapePath = [UIBezierPath bezierPathWithRoundedRect:blockSelf.theLeftView.bounds
                                                                        byRoundingCorners:UIRectCornerTopLeft | UIRectCornerBottomLeft
                                                                              cornerRadii:CGSizeMake(6.0, 6.0)];
                        CAShapeLayer* shapeLayer = [[CAShapeLayer alloc] init];
                        shapeLayer.path = shapePath.CGPath;
                        blockSelf.theLeftView.layer.mask = shapeLayer;
                        [blockSelf addSubview:blockSelf.theLeftView];

                        CGRect ghostFrame = CGRectZero;
                        ghostFrame.size = imageView.frame.size;
                        self.ghostView.frame = ghostFrame;
                        [imageView addSubview:self.ghostView];
                        
                        UIView* spinningCrank = [blockSelf createWaitingView];
                        spinningCrank.tag = SPINNER_VIEW_TAG;
                        spinningCrank.center = imageView.center;
                        [imageView addSubview:spinningCrank];
                        
                        CGSize maxTextSize = CGSizeMake(PTCHATVIEW_SUBVIEW_WIDTH, PTCHATVIEW_SUBVIEW_HEIGHT/4.0);
                        CGSize computedLabelSize = [text sizeWithFont:[[blockSelf class] nameFont]
                                                    constrainedToSize:maxTextSize];
                        
                        CGFloat labelOriginX = CGRectGetMidX(imageView.bounds) - computedLabelSize.width/2.0;
                        CGFloat labelOriginY = CGRectGetHeight(imageView.bounds) - computedLabelSize.height;
                        UILabel* nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(labelOriginX, labelOriginY,
                                                                                       computedLabelSize.width, computedLabelSize.height)];
                        nameLabel.font = [[blockSelf class] nameFont];
                        nameLabel.text = text;
                        nameLabel.backgroundColor = [UIColor clearColor];
                        nameLabel.textColor = [UIColor blackColor];
                        nameLabel.tag = NAME_VIEW_TAG;
                        [imageView addSubview:nameLabel];

    }];

    [self.theLeftView addSubview:self.leftImageView];
}

-(UIView*)createWaitingView {
    UIImage *loadingIcon = [UIImage imageNamed:@"logo_loading.gif"];
    UIImageView *iconImageview = [[UIImageView alloc] initWithImage:loadingIcon];
    iconImageview.frame = CGRectMake(0, 0, loadingIcon.size.width, loadingIcon.size.height);
    
    CATransform3D rotationsTransform = CATransform3DMakeRotation(1.0f * M_PI, 0, 0, 1.0);
    CABasicAnimation *rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
    
    rotationAnimation.toValue = [NSValue valueWithCATransform3D:rotationsTransform];
    rotationAnimation.duration = 2.0f;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = 10000;

    [iconImageview.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
    return iconImageview;
}

+ (UIFont*)nameFont {
    return [UIFont fontWithName:@"TeluguSangamMN" size:20.0];
}

- (void)transitionLeftImage {
    [[self.leftImageView viewWithTag:SPINNER_VIEW_TAG] removeFromSuperview];
    [[self.leftImageView viewWithTag:NAME_VIEW_TAG] removeFromSuperview];

    [UIView animateWithDuration:0.5 animations:^{
        self.ghostView.alpha = 0.0;
        [self bringSubviewToFront:self.theLeftView];

        self.theLeftView.layer.borderColor = [self photoBorderColor].CGColor;
        self.theLeftView.layer.borderWidth = 6.0;
    } completion:^(BOOL finished) {
        [self removeGhostView];
    }];
}

- (void)removeGhostView {
    [self.ghostView removeFromSuperview];
    self.ghostView = nil;
}


- (UIColor*)photoBorderColor {
    return [UIColor whiteColor];
}

- (void)setImageForRightView:(UIImage*)anImage {

    self.rightImageView.image = anImage;
    self.rightImageView.frame = [[self class] rectForLeftView];
    self.rightImageView.layer.borderWidth = 6.0;
    self.rightImageView.layer.borderColor = [self photoBorderColor].CGColor;
    [self.theRightView addSubview:self.rightImageView];
}

- (void)setLeftView:(UIView*)aView {
    self.theLeftView.layer.borderWidth = 0.0;
    
    aView.frame = [[self class] rectForLeftView];
    self.leftVideoView = aView;
    [aView removeAllGestureRecognizers];

    UIBezierPath* cornerPath = [UIBezierPath bezierPathWithRoundedRect:aView.bounds
                                                     byRoundingCorners:UIRectCornerTopLeft | UIRectCornerBottomLeft
                                                           cornerRadii:CGSizeMake(6.0, 6.0)];
    CAShapeLayer* shapeLayer = [[CAShapeLayer alloc] init];
    shapeLayer.path = cornerPath.CGPath;
    [self.theLeftView removeFromSuperview];
    self.theLeftView.layer.mask = shapeLayer;

    [self.leftImageView removeFromSuperview];
    [self.theLeftView addSubview:aView];
    [self addSubview:self.theLeftView];
    [self bringSubviewToFront:self.theLeftView];
}

- (void)setRightView:(UIView*)aView {

    CGRect viewFrame = [[self class] rectForLeftView];

    aView.frame = viewFrame;
    self.rightVideoView = aView;
    [aView removeAllGestureRecognizers];

    UIBezierPath* cornerPath = [UIBezierPath bezierPathWithRoundedRect:aView.bounds
                                                     byRoundingCorners:UIRectCornerTopRight | UIRectCornerBottomRight
                                                           cornerRadii:CGSizeMake(6.0, 6.0)];
    CAShapeLayer* shapeLayer = [[CAShapeLayer alloc] init];
    shapeLayer.path = cornerPath.CGPath;
    [self.theRightView removeFromSuperview];
    self.theRightView.layer.mask = shapeLayer;

    [self.rightImageView removeFromSuperview];
    [self.theRightView addSubview:aView];
    [self addSubview:self.theRightView];
}

- (void)setLeftImagePlaceholderWithURL:(NSString*)aURL {
    if ([self.theLeftView isKindOfClass:[UIImageView class]]) {
        UIImageView* leftView = (UIImageView*)self.theLeftView;
        [leftView setImageWithAURL:[NSURL URLWithString:aURL]
                            origin:CGPointZero
                           maxSize:CGSizeMake(PTCHATVIEW_SUBVIEW_WIDTH, PTCHATVIEW_SUBVIEW_HEIGHT)
                       completeion:NULL];
    }
}

- (void)setRightImagePlaceholderWithURL:(NSString*)aURL {
    if ([self.theRightView isKindOfClass:[UIImageView class]]) {
        UIImageView* rightView = (UIImageView*)self.theRightView;
        [rightView setImageWithURLString:aURL];
    }
}

@end
