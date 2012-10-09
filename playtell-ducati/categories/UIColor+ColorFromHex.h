//
//  UIColor+ColorFromHex.h
//  playtell-ducati
//
//  Created by Dimitry Bentsionov on 8/29/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (ColorFromHex)

+ (UIColor *)colorFromHex:(NSString *)hexColor;
+ (UIColor *)colorFromHex:(NSString *)hexColor alpha:(CGFloat)alpha;

@end