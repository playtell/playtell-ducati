//
//  UIImageView+Animation.h
//  playtell-ducati
//
//  Created by Ricky Hussmann on 8/30/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

// Lovingly lifted from http://stackoverflow.com/questions/1632364/shake-visual-effect-on-iphone-not-shaking-the-device/1827373#1827373

#import <UIKit/UIKit.h>

@interface UIImageView (Animation)

- (void)earthquake;

- (void)flipOverWithIsBackUp:(BOOL)backUp
                  frontImage:(UIImage *)front
                   backImage:(UIImage *)back;

@end