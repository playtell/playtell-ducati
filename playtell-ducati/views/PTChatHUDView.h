//
//  PTChatHUDView.h
//  PlayTell
//
//  Created by Ricky Hussmann on 5/3/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PTChatHUDView : UIView

// Need to remove all these methods once everything is refactored...
- (void)setLoadingImageForLeftView:(UIImage*)anImage loadingText:(NSString*)text;
- (void)setLoadingImageForRightView:(UIImage*)anImage;

// ... and keep these.
- (void)setLeftView:(UIView*)aView;
- (void)setRightView:(UIView*)aView;

@end
