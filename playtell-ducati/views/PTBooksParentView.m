//
//  PTBooksParentView.m
//  PlayTell
//
//  Created by Dimitry Bentsionov on 5/21/12.
//  Copyright (c) 2012 PlayTell. All rights reserved.
//

#import "PTBooksParentView.h"

@implementation PTBooksParentView

@synthesize isBookOpen;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        scrollView = nil;
        isBookOpen = NO;
    }
    return self;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if (isBookOpen || !CGRectContainsPoint(self.bounds, point)) {
        return nil;
    }

    UIView *result = nil;
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

- (void)addSubview:(UIView *)view {
    [super addSubview:view];
    if ([view isKindOfClass:[PTBooksScrollView class]]) {
        scrollView = (PTBooksScrollView *)view;
    }
}

@end
