//
//  PTConcretePlaymateFactory.m
//  playtell-ducati
//
//  Created by Ricky Hussmann on 6/10/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import "Logging.h"
#import "PTAllFriendsRequest.h"
#import "PTConcretePlaymateFactory.h"
#import "PTUser.h"

@interface PTConcretePlaymateFactory ()
@property (nonatomic, retain) NSArray* playmates;
@end

static PTConcretePlaymateFactory* sharedInstance =  nil;

@implementation PTConcretePlaymateFactory
@synthesize playmates;

+ (PTConcretePlaymateFactory*)sharedFactory {
    if(!sharedInstance) {
        sharedInstance = [[self alloc] init];
    }
    return sharedInstance;
}

- (PTPlaymate*)playmateWithId:(NSUInteger)playmateId {
    PTUser* currentUser = [PTUser currentUser];
    if (playmateId == currentUser.userID) {
        return currentUser;
    }

    PTPlaymate* returnPlaymate = nil;
    for (PTPlaymate* playmate in self.playmates) {
        if (playmate.userID == playmateId) {
            returnPlaymate = playmate;
        }
    }
    return returnPlaymate;
}

- (PTPlaymate*)playmateWithUsername:(NSString*)username {
    PTUser* currentUser = [PTUser currentUser];
    if ([[username lowercaseString] isEqualToString:[currentUser username]]) {
        return currentUser;
    }

    PTPlaymate* returnPlaymate = nil;
    for (PTPlaymate* playmate in self.playmates) {
        if ([[playmate.username lowercaseString] isEqualToString:[username lowercaseString]]) {
            returnPlaymate = playmate;
        }
    }
    return returnPlaymate;
}

- (NSArray*)allPlaymates {
    return self.playmates;
}

- (void)refreshPlaymatesForUserID:(NSUInteger)ID
                            token:(NSString*)token
                          success:(void(^)(void))success
                          failure:(void(^)(NSError* error))failure {
    PTAllFriendsRequest* request = [[PTAllFriendsRequest alloc] init];
    [request allFriendsWithUserID:ID
                        authToken:token
                          success:^(NSDictionary *result)
    {
        NSArray* friends = [result valueForKey:@"friends"];
        NSMutableArray* playmateList = [NSMutableArray arrayWithCapacity:friends.count];
        for (NSDictionary* playmate in friends) {
            LogTrace(@"id: %@, email: %@, displayName: %@, profilePhoto: %@",
                     [playmate valueForKey:@"id"], [playmate valueForKey:@"email"],
                     [playmate valueForKey:@"displayName"], [playmate valueForKey:@"profilePhoto"]);

            PTPlaymate* playmateObject = [[PTPlaymate alloc] initWithDictionary:playmate];
            [playmateList addObject:playmateObject];
        }
        self.playmates = playmateList;

        if (success) {
            success();
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        LogError(@"%@ - error: %@", NSStringFromSelector(_cmd), error);
        if (failure) {
            failure(error);
        }
    }];
}

@end
