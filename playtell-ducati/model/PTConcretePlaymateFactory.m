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
@property (nonatomic, retain) NSMutableArray* playmates;
@end

static PTConcretePlaymateFactory* sharedInstance = nil;

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
            break;
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
            break;
        }
    }
    return returnPlaymate;
}

- (NSArray*)allPlaymates {
    return self.playmates;
}

- (void)addPlaymate:(PTPlaymate *)playmate {
    [self.playmates insertObject:playmate atIndex:0];
}

- (void)removePlaymateUsingId:(NSUInteger)playmateId {
    PTPlaymate *playmate = [self playmateWithId:playmateId];
    if (playmate == nil) {
        return;
    }
    
    [self.playmates removeObject:playmate];
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
        self.playmates = [NSMutableArray array];
        for (NSDictionary* playmate in friends) {
//            LogTrace(@"id: %@, email: %@, displayName: %@, profilePhoto: %@",
//                     [playmate valueForKey:@"id"], [playmate valueForKey:@"email"],
//                     [playmate valueForKey:@"displayName"], [playmate valueForKey:@"profilePhoto"]);

            PTPlaymate* playmateObject = [[PTPlaymate alloc] initWithDictionary:playmate];
            [self.playmates addObject:playmateObject];
        }

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