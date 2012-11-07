//
//  PTChatHUDView.h
//  PlayTell
//
//  Created by Ricky Hussmann on 5/3/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Opentok/Opentok.h>

@interface PTChatHUDView : UIView {
    BOOL isBorderShown;
    CAShapeLayer *containerMaskLayer;
    CAShapeLayer *containerShadowLayer;
    CAShapeLayer *contentMaskLayer;
    CAShapeLayer *contentShadowLayer;
}

@property (nonatomic, weak) OTVideoView *publisherView;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UIView *containerShadowView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIView *contentShadowView;

- (void)setLoadingImageForView:(UIImage*)anImage;
- (void)setView:(UIView*)aView;
- (void)showBorder;
- (void)hideBorder;

@end