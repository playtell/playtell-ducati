//
//  PTChatHUDView.h
//  PlayTell
//
//  Created by Ricky Hussmann on 5/3/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Opentok/Opentok.h>

@interface PTChatHUDView : UIView

@property (nonatomic, weak) OTVideoView *publisherView;

- (void)setLoadingImageForView:(UIImage*)anImage;
- (void)setView:(UIView*)aView;

@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UIView *contentView;

@end