//
//  PTFriendshipAcceptRequest.h
//  playtell-ducati
//
//  Created by Dimitry Bentsionov on 9/4/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import "PTRequest.h"

typedef void (^PTFriendshipAcceptRequestSuccessBlock) (NSDictionary* result);
typedef void (^PTFriendshipAcceptRequestFailureBlock) (NSURLRequest* request, NSHTTPURLResponse* response, NSError* error, id JSON);

@interface PTFriendshipAcceptRequest : PTRequest

- (void)acceptFriendshipWith:(NSInteger)userId
                   authToken:(NSString*)token
                     success:(PTFriendshipAcceptRequestSuccessBlock)success
                     failure:(PTFriendshipAcceptRequestFailureBlock)failure;

@end