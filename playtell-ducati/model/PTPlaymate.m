//
//  PTPlaymate.m
//  playtell-ducati
//
//  Created by Ricky Hussmann on 6/1/12.
//  Copyright (c) 2012 PlayTell. All rights reserved.
//

#import "PTPlaymate.h"

@implementation PTPlaymate
@synthesize email;
@synthesize username;
@synthesize userID;
@synthesize photoURL;
@synthesize userPhoto;
@synthesize friendshipStatus;
@synthesize userStatus;

// TODO: Need to route this through the dictionary initializer
- (id)initWithEmail:(NSString*)anEmail username:(NSString*)aName userID:(NSUInteger)aUserID {
    if (self = [super init]) {
        email = [anEmail copy];
        username = [aName copy];
        userID = aUserID;
        friendshipStatus = @"confirmed";
        userStatus = @"available";
    }
    return self;
}

- (id)initWithDictionary:(NSDictionary*)playmateDictionary {
    if (self = [super init]) {
        self.email = [playmateDictionary valueForKey:@"email"];
        self.username = [playmateDictionary valueForKey:@"displayName"];
        self.friendshipStatus = [playmateDictionary valueForKey:@"friendshipStatus"];
        self.userStatus = [playmateDictionary valueForKey:@"userStatus"];
        self.userID = [[playmateDictionary valueForKey:@"id"] unsignedIntValue];

        NSURL* url = [NSURL URLWithString:[playmateDictionary valueForKey:@"profilePhoto"]];
        self.photoURL = url;
    }
    return  self;
}

- (NSString*)description {
    return [NSString stringWithFormat:@"Username: %@, Email: %@, UserID: %u, FriendshipStatus: %@ UserStatus: %@", self.username, self.email, self.userID, self.friendshipStatus, self.userStatus];
}

@end
