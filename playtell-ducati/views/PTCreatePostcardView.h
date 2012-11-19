//
//  PTCreatePostcardView.h
//  playtell-ducati
//
//  Created by Adam Horne on 11/1/12.
//  Copyright (c) 2012 PlayTell. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PTCreatePostcardViewDelegate <NSObject>
@required
- (void)postcardTaken:(UIImage *)postcard withScreenshot:(UIImage *)screenshot;
@end

@interface PTCreatePostcardView : UIView <UIGestureRecognizerDelegate>

@property (nonatomic, strong) id<PTCreatePostcardViewDelegate> delegate;

- (void)startPhotoCountdown;

@end
