//
//  PTPostcardView.h
//  playtell-ducati
//
//  Created by Adam Horne on 11/1/12.
//  Copyright (c) 2012 PlayTell. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PTPostcardViewDelegate <NSObject>
@required
- (void)postcardTaken:(UIImage *)postcard withScreenshot:(UIImage *)screenshot;
@end

@interface PTPostcardView : UIView

@property (nonatomic, strong) id<PTPostcardViewDelegate> delegate;

- (void)startPhotoCountdown;

@end
