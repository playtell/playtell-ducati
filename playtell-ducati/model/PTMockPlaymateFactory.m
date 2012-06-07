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
    
    PTPlaymate* dima = [[PTPlaymate alloc] initWithEmail:@"dimitryb@gmail.com"
                                                username:@"dima"
                                                  userID:43];
    
    PTPlaymate* dimaTest = [[PTPlaymate alloc] initWithEmail:@"dimitry@playtell.com"
                                                     username:@"dima"
                                                       userID:44];

    PTPlaymate* semiratest2 = [[PTPlaymate alloc] initWithEmail:@"srahemtulla@gmail.com"
                                                       username:@"semiratest2"
                                                         userID:40];

    PTPlaymate* jasontest = [[PTPlaymate alloc] initWithEmail:@"jasontest@playtell.com"
                                                     username:@"jasontest"
                                                       userID:39];

    PTPlaymate* semira = [[PTPlaymate alloc] initWithEmail:@"semira@playtell.com"
                                                  username:@"semira"
                                                    userID:24];

    PTPlaymate* jason_test = [[PTPlaymate alloc] initWithEmail:@"jdep01@gmail.com"
                                                      username:@"jason_test"
                                                        userID:36];

    PTPlaymate* jason_t2 = [[PTPlaymate alloc] initWithEmail:@"jason@gmail.com"
                                                    username:@"jason_t2"
                                                      userID:37];

    PTPlaymate* jason = [[PTPlaymate alloc] initWithEmail:@"jason@playtell.com"
                                                 username:@"jason"
                                                   userID:17];

    PTPlaymate* brad = [[PTPlaymate alloc] initWithEmail:@"brad@playtell.com"
                                                username:@"brad"
                                                  userID:42];

    PTPlaymate* semiratest1 = [[PTPlaymate alloc] initWithEmail:@"semira@gmail.com"
                                                       username:@"semiratest1"
                                                         userID:41];

    playmates = [NSArray arrayWithObjects:ricky, rickyTest, dima, dimaTest, semiratest2,
                 jasontest, semira, jason_test, jason_t2, jason, brad, semiratest1, nil];
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

- (PTPlaymate*)playmateWithUsername:(NSString*)username {
    PTPlaymate* returnPlaymate = nil;
    for (PTPlaymate* playmate in playmates) {
        if ([[playmate.username lowercaseString] isEqualToString:[username lowercaseString]]) {
            returnPlaymate = playmate;
        }
    }
    return returnPlaymate;
}

- (NSArray*)allPlaymates {
    return playmates;
}

@end
