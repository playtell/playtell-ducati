//
//  PTUser.m
//  playtell-ducati
//
//  Created by Ricky Hussmann on 6/1/12.
//  Copyright (c) 2012 PlayTell. All rights reserved.
//

#import "PTUser.h"

@implementation PTUser
@synthesize authToken;

static PTUser* instance = nil;

+ (PTUser*)currentUser {
    if (instance == nil) {
        instance = [[PTUser alloc] init];
    }
    return instance;
}

- (NSString*)description {
    NSString* description = [super description];
    return [description stringByAppendingFormat:@", token=%@", self.authToken];
}

@end
