//
//  PTNewUser.m
//  playtell-ducati
//
//  Created by Dimitry Bentsionov on 9/12/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import "PTNewUser.h"

@implementation PTNewUser

@synthesize isCreateViaFacebook;
@synthesize isAccountForChild;
@synthesize isNotificationsApproved;
@synthesize name;
@synthesize email;
@synthesize password;
@synthesize photo;
@synthesize birthday;

- (id)init {
    self = [super init];
    if (self) {
        self.isAccountForChild = NO;
    }
    return self;
}

@end