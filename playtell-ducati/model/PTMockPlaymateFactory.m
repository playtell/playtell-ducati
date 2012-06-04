//
//  PTMockPlaymateFactory.m
//  playtell-ducati
//
//  Created by Ricky Hussmann on 6/2/12.
//  Copyright (c) 2012 PlayTell. All rights reserved.
//

#import "PTMockPlaymateFactory.h"

@implementation PTMockPlaymateFactory
static NSArray* playmates;

// NOTE this is my test list of users. If you're working with live playdate requests
// and the user in those requests are not created inside this initialize method, you
// won't be able to generate that playmate.

+ (void)initialize {
    PTPlaymate* ricky = [[PTPlaymate alloc] initWithEmail:@"ricky@playtell.com"
                                                 username:@"ricky"
                                                   userID:18];

    PTPlaymate* rickyTest = [[PTPlaymate alloc] initWithEmail:@"rickytest@playtell.com"
                                                     username:@"rickytest"
                                                       userID:25];

    playmates = [NSArray arrayWithObjects:ricky, rickyTest, nil];
}

- (PTPlaymate*)playmateWithId:(NSUInteger)playmateId {
    PTPlaymate* returnPlaymate = nil;
    for (PTPlaymate* playmate in playmates) {
        if (playmate.userID == playmateId) {
            returnPlaymate = playmate;
        }
    }
    return returnPlaymate;
}

- (NSArray*)allPlaymates {
    return [NSArray array];
}

@end
