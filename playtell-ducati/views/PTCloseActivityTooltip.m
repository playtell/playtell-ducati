//
//  PTCloseActivityTooltip.m
//  playtell-ducati
//
//  Created by Ricky Hussmann on 9/27/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import "PTCloseActivityTooltip.h"

@implementation PTCloseActivityTooltip

- (NSString*)toolTipImageName {
    return @"close-activity";
}

- (CGFloat)caretXFractionOfWidth {
    return 202.0f / 225.0f;
}

- (CGFloat)caretYFractionOfHeight {
    return 38.0f / 95.0f;
}

@end
