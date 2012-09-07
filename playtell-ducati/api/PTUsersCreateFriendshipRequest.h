//
//  PTUsersCreateFriendship.h
//  playtell-ducati
//
//  Created by Dimitry Bentsionov on 8/9/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import "PTRequest.h"

typedef void (^PTUsersCreateFriendshipRequestSuccessBlock) (NSDictionary* result);
typedef void (^PTUsersCreateFriendshipRequestFailureBlock) (NSURLRequest* request, NSHTTPURLResponse* response, NSError* error, id JSON);

@interface PTUsersCreateFriendshipRequest : PTRequest

- (void)userCreateFriendship:(NSInteger)user_id
                   authToken:(NSString *)token
                     success:(PTUsersCreateFriendshipRequestSuccessBlock)success
                     failure:(PTUsersCreateFriendshipRequestFailureBlock)failure;

@end
