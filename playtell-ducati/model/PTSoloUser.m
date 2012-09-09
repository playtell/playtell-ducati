//
//  PTSoloUser.m
//  playtell-ducati
//
//  Created by Ricky Hussmann on 9/6/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import "PTSoloUser.h"

@implementation PTSoloUser

- (NSURL*)photoURL {
    return [[NSBundle mainBundle] URLForResource:@"dialpad-live"
                                   withExtension:@"png"];
}

- (UIImage*)userPhoto {
    return [UIImage imageNamed:@"dialad-live"];
}

- (NSString*)email {
    return @"solo@playtell.com";
}

- (NSUInteger)userID {
    return -1;
}

- (NSString*)username {
    return @"Solo";
}

@end
