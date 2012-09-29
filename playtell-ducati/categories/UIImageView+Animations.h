//
//  UIImageView+Animations.h
//  playtell-ducati
//
//  Created by Giancarlo D on 9/28/12. w/ Ricky Hussman
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (Animations)

- (void)earthquake;

- (void)flipOverWithIsBackUp:(BOOL)backUp
                  frontImage:(UIImage *)front
                   backImage:(UIImage *)back;

@end