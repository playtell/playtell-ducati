//
//  PTMatchingAvailableCardsView.m
//  playtell-ducati
//
//  Created by Dimitry Bentsionov on 10/25/12.
//  Copyright (c) 2012 PlayTell. All rights reserved.
//

#import "PTMatchingAvailableCardsView.h"

@implementation PTMatchingAvailableCardsView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if (!CGRectContainsPoint(self.bounds, point)) {
        return nil;
    }
    
    UIView *result = nil;
    UIScrollView *scrollView = [self.subviews objectAtIndex:0];
    for (UIView *child in scrollView.subviews) {
        CGPoint point2 = [self convertPoint:point toView:child];
        if ([child pointInside:point2 withEvent:event]) {
            if ((result = [child hitTest:point2 withEvent:event]) != nil) {
                break;
            }
        }
    }
    return result == nil ? scrollView : result;
}

@end
