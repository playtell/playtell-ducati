//
//  PTFriendTouchTooltip.m
//  playtell-ducati
//
//  Created by Ricky Hussmann on 9/2/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import "PTFriendTouchTooltip.h"

@implementation PTFriendTouchTooltip

- (NSString*)toolTipImageName {
    return @"buddy-point";
}

- (CGFloat)caretXFractionOfWidth {
    return 222.0f / 336.0f;
}

- (CGFloat)caretYFractionOfHeight {
    return 90.0f / 120.0f;
}

@end
