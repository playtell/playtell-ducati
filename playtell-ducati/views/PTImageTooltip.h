//
//  PTImageTooltip.h
//  playtell-ducati
//
//  Created by Ricky Hussmann on 9/2/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PTImageTooltip : UIImageView

// Designated initializer
- (id)initWithWidth:(CGFloat)toolTipWidth;
- (void)addToView:(UIView*)aView withCaretAtPoint:(CGPoint)caretPoint;

// For subclasses
- (NSString*)toolTipImageName;
- (CGFloat)caretXFractionOfWidth;
- (CGFloat)caretYFractionOfHeight;
@end
