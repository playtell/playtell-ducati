//
//  PTPlaymate.m
//  playtell-ducati
//
//  Created by Ricky Hussmann on 6/1/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import "PTPlaymate.h"

@implementation PTPlaymate
@synthesize email;
@synthesize username;
@synthesize userID;

- (id)initWithEmail:(NSString*)anEmail username:(NSString*)aName userID:(NSUInteger)aUserID {
    if (self = [super init]) {
        email = [anEmail copy];
        username = [aName copy];
        userID = aUserID;
    }
    return self;
}

- (NSString*)description {
    return [NSString stringWithFormat:@"Username: %@, Email: %@, UserID: %u", self.username, self.email, self.userID];
}

@end
