//
//  PTNullPlaymate.m
//  playtell-ducati
//
//  Created by Ricky Hussmann on 9/10/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import "PTNullPlaymate.h"

@implementation PTNullPlaymate

- (NSURL*)photoURL {
    return [[NSBundle mainBundle] URLForResource:@"profile_default_2"
                                   withExtension:@"png"];
}

- (UIImage*)userPhoto {
    return [UIImage imageNamed:@"profile_default_2"];
}

- (NSString*)email {
    return @"";
}

- (NSUInteger)userID {
    return -2;
}

- (NSString*)username {
    return @"";
}

@end
