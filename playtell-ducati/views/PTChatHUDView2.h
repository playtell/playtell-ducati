//
//  PTChatHUDView2.h
//  playtell-ducati
//
//  Created by Ricky Hussmann on 9/24/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PTChatHUDView2 : UIView {
    int playdateId;
}

@property (nonatomic, assign) int playdateId;

// Need to remove all these methods once everything is refactored...
- (void)setLoadingImageForLeftView:(UIImage*)anImage loadingText:(NSString*)text;
- (void)setLoadingImageForLeftViewWithURL:(NSURL*)aURL loadingText:(NSString*)text;
- (void)setLoadingImageForRightView:(UIImage*)anImage;
- (void)transitionLeftImage;
- (void)setImageForRightView:(UIImage*)anImage;
- (void)restrictToSmallSize:(BOOL)shouldRestrict;

// ... and keep these.
- (void)setLeftView:(UIView*)aView;
- (void)setRightView:(UIView*)aView;

@end