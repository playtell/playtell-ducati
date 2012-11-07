//
//  PTChatHUDParentView.m
//  playtell-ducati
//
//  Created by Dimitry Bentsionov on 11/6/12.
//  Copyright (c) 2012 PlayTell. All rights reserved.
//

#import "PTChatHUDParentView.h"

@implementation PTChatHUDParentView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *result = nil;
    for (UIView *child in self.subviews) {
        CGPoint point2 = [self convertPoint:point toView:child];
        if ([child pointInside:point2 withEvent:event]) {
            if ((result = [child hitTest:point2 withEvent:event]) != nil) {
                break;
            }
        }
    }
    return result;
}

@end