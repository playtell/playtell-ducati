//
//  PTTouchHereTooltip.m
//  playtell-ducati
//
//  Created by Ricky Hussmann on 9/2/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import "PTTouchHereTooltip.h"

@implementation PTTouchHereTooltip

- (NSString*)toolTipImageName {
    return @"point-here";
}

- (CGFloat)caretXFractionOfWidth {
    return 88.0 / 201.0;
}

- (CGFloat)caretYFractionOfHeight {
    return 125.0 / 185.0;
}

@end