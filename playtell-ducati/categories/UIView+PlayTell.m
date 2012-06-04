//
//  UIView+PlayTell.m
//  PlayTell
//
//  Created by Ricky Hussmann on 4/27/12.
//  Copyright (c) 2012 PlayTell. All rights reserved.
//

#import "UIView+PlayTell.h"

#import <QuartzCore/QuartzCore.h>

@implementation UIView (PlayTell)

- (void)addSubviewAndCenter:(UIView*)aView {
    CGRect viewFrame = aView.frame;
    viewFrame.origin = CGPointMake(CGRectGetMidX(self.bounds) - CGRectGetWidth(viewFrame)/2.0,
                                   CGRectGetMidY(self.bounds) - CGRectGetHeight(viewFrame)/2.0);
    
    aView.frame = viewFrame;
    [self addSubview:aView];
}

- (void)removeAllGestureRecognizers {
    NSArray* allRecognizers = [NSArray arrayWithArray:self.gestureRecognizers];
    [allRecognizers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UIGestureRecognizer* recognizer = (UIGestureRecognizer*)obj;
        [self removeGestureRecognizer:recognizer];
    }];
}

- (UIImage*)screenshot {
	UIGraphicsBeginImageContext(self.frame.size);
	[self.layer renderInContext:UIGraphicsGetCurrentContext()];
	UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
    UIImageWriteToSavedPhotosAlbum(viewImage, nil, nil, nil);
    return viewImage;
}

@end
