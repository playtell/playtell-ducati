//
//  PTFriendshipDeclineRequest.h
//  playtell-ducati
//
//  Created by Dimitry Bentsionov on 9/4/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import "PTRequest.h"

typedef void (^PTFriendshipDeclineRequestSuccessBlock) (NSDictionary* result);
typedef void (^PTFriendshipDeclineRequestFailureBlock) (NSURLRequest* request, NSHTTPURLResponse* response, NSError* error, id JSON);

@interface PTFriendshipDeclineRequest : PTRequest

- (void)declineFriendshipFrom:(NSInteger)userId
                    authToken:(NSString*)token
                      success:(PTFriendshipDeclineRequestSuccessBlock)success
                      failure:(PTFriendshipDeclineRequestFailureBlock)failure;

@end