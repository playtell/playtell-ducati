//
//  PTHangmanDrawboard.m
//  playtell-ducati
//
//  Created by Dimitry Bentsionov on 12/19/12.
//  Copyright (c) 2012 PlayTell. All rights reserved.
//

#import "PTHangmanDrawboard.h"
#import "UIColor+HexColor.h"

@implementation PTHangmanDrawboard

@synthesize isDrawing;

@synthesize delegate;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setMultipleTouchEnabled:NO];
        [self setBackgroundColor:[UIColor clearColor]];
        path = [UIBezierPath bezierPath];
        [path setLineWidth:3.0];
        isDrawing = NO;
        emptyPath = YES;
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    [incrementalImage drawInRect:rect];
    [[UIColor colorFromHex:@"#d1775f"] setStroke];
    [path stroke];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (isDrawing == NO) {
        return;
    }
    UITouch *touch = [touches anyObject];
    CGPoint p = [touch locationInView:self];
    [self notifyDelegateOfPoint:p];
    [path moveToPoint:p];
    emptyPath = NO;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if (isDrawing == NO) {
        return;
    }
    UITouch *touch = [touches anyObject];
    CGPoint p = [touch locationInView:self];
    [self notifyDelegateOfPoint:p];
    [path addLineToPoint:p];
    [self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (isDrawing == NO) {
        return;
    }
    UITouch *touch = [touches anyObject];
    CGPoint p = [touch locationInView:self];
    [self notifyDelegateOfPoint:p];
    [self notifyDelegateOfPoint:CGPointMake(-1000, -1000)]; // Means last point...
    [path addLineToPoint:p];
    [self drawBitmap];
    [self setNeedsDisplay];
    [path removeAllPoints];
    emptyPath = YES;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    if (isDrawing == NO) {
        return;
    }
    [self touchesEnded:touches withEvent:event];
}

- (void)drawBitmap {
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 0.0);
    [[UIColor blackColor] setStroke];
    [incrementalImage drawAtPoint:CGPointZero];
    [[UIColor colorFromHex:@"#d1775f"] setStroke];
    [path stroke];
    incrementalImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}

- (void)notifyDelegateOfPoint:(CGPoint)point {
    if (isDrawing == NO) {
        return;
    }

    if ([delegate respondsToSelector:@selector(drawboardDidDraw:)]) {
        [delegate drawboardDidDraw:point];
    }
}

- (void)addPointToBoard:(CGPoint)point {
    if (point.x == -1000 && point.y == -1000) {
        [self drawBitmap];
        [self setNeedsDisplay];
        [path removeAllPoints];
        emptyPath = YES;
        return;
    }
    
    if (emptyPath == YES) {
        [path moveToPoint:point];
        emptyPath = NO;
    } else {
        [path addLineToPoint:point];
    }
    [self setNeedsDisplay];
}

@end