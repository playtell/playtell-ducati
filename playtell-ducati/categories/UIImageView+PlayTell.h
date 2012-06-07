//
//  UIImageView+PlayTell.h
//  PlayTell
//
//  Created by Ricky Hussmann on 5/4/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^PTImageLoadedBlock)(UIImageView* imageView);

@interface UIImageView (PlayTell)
- (void)setImageWithURLString:(NSString*)aString;
- (void)setImageWithAURL:(NSURL*)aURL;
- (void)setImageWithAURL:(NSURL*)aURL origin:(CGPoint)aPoint maxSize:(CGSize)aSize completeion:(PTImageLoadedBlock)completionHandler;
@end
