//
//  PTChatHUDView.h
//  PlayTell
//
//  Created by Ricky Hussmann on 5/3/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^PTChatHUDViewReconnectBlock) (void);

@interface PTChatHUDView : UIView

- (void)setLoadingImageForLeftView:(UIImage*)anImage loadingText:(NSString*)text;
- (void)setLoadingImageForLeftViewWithURL:(NSURL*)aURL loadingText:(NSString*)text;
- (void)setLoadingImageForRightView:(UIImage*)anImage;
- (void)transitionLeftImage;
- (void)setImageForRightView:(UIImage*)anImage;
- (void)setLeftView:(UIView*)aView;
- (void)setRightView:(UIView*)aView;

- (void)enableReconnectViewWithClickHandler:(PTChatHUDViewReconnectBlock)handler;
@end
