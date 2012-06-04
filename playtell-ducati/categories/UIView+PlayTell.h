//
//  UIView+PlayTell.h
//  PlayTell
//
//  Created by Ricky Hussmann on 4/27/12.
//  Copyright (c) 2012 PlayTell. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (PlayTell)

- (void)addSubviewAndCenter:(UIView*)aView;

- (void)removeAllGestureRecognizers;
- (UIImage*)screenshot;

@end
