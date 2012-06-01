//
//  PTTextField.m
//  PlayTell
//
//  Created by Ricky Hussmann on 3/22/12.
//  Copyright (c) 2012 PlayTell. All rights reserved.
//

#import "PTTextField.h"

#define LEFT_INSET 10.0

@interface PTTextField ()
- (CGRect)insetRectForBounds:(CGRect)bounds;
@end

@implementation PTTextField

- (CGRect)editingRectForBounds:(CGRect)bounds {
    return [self insetRectForBounds:bounds];
}

- (CGRect)textRectForBounds:(CGRect)bounds {
    return [self insetRectForBounds:bounds];
}

- (CGRect)insetRectForBounds:(CGRect)bounds {    
    CGFloat rectWidth = CGRectGetWidth(bounds);
    CGFloat newWidth = rectWidth - LEFT_INSET;
    CGRect returnRect = CGRectOffset(bounds, LEFT_INSET, 5.0);
    returnRect.size.width = newWidth;
    return returnRect;
}

- (void) drawPlaceholderInRect:(CGRect)rect {
    [UIColorFromRGB(0x397684) setFill];
    [[self placeholder] drawInRect:rect withFont:self.font];
}

@end
