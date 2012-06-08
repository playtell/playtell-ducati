//
//  PTPlaydate+InitatorChecking.m
//  playtell-ducati
//
//  Created by Ricky Hussmann on 6/7/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import "PTPlaydate+InitatorChecking.h"

@implementation PTPlaydate (InitatorChecking)

- (BOOL)isUserIDInitiator:(NSUInteger)userID {
    return (self.initiator.userID == userID);
}

@end
