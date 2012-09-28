//
//  PTEndCallTooltip.m
//  playtell-ducati
//
//  Created by Ricky Hussmann on 9/28/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import "PTEndCallTooltip.h"

@implementation PTEndCallTooltip

- (NSString*)toolTipImageName {
    return @"end-call";
}

- (CGFloat)caretXFractionOfWidth {
    return 0.0f / 206.0f;
}

- (CGFloat)caretYFractionOfHeight {
    return 37.0f / 112.0f;
}

@end
