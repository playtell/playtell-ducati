//
//  PTAllFriendsRequest.h
//  playtell-ducati
//
//  Created by Ricky Hussmann on 6/8/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import "PTRequest.h"

typedef void (^PTAllFriendsRequestSuccessBlock) (NSDictionary* result);
typedef void (^PTAllFriendsRequestFailureBlock) (NSURLRequest* request, NSHTTPURLResponse* response, NSError* error, id JSON);

@interface PTAllFriendsRequest : PTRequest

- (void)allFriendsWithUserID:(NSUInteger)userID
                   authToken:(NSString*)token
                     success:(PTAllFriendsRequestSuccessBlock)success
                     failure:(PTAllFriendsRequestFailureBlock)failure;

@end
