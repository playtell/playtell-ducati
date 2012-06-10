//
//  PTAllFriendsRequest.m
//  playtell-ducati
//
//  Created by Ricky Hussmann on 6/8/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import "AFNetworking.h"
#import "Logging.h"
#import "PTAllFriendsRequest.h"

#import "NSMutableURLRequest+POSTParameters.h"

@implementation PTAllFriendsRequest

- (void)allFriendsWithUserID:(NSUInteger)userID
                   authToken:(NSString*)token
                     success:(PTAllFriendsRequestSuccessBlock)success
                     failure:(PTAllFriendsRequestFailureBlock)failure {
    LOGMETHOD;

    NSString* allFriendsEndpoint = [NSString stringWithFormat:@"%@/api/users/all_friends.json", ROOT_URL];
    NSURL* allFriendsURL = [NSURL URLWithString:allFriendsEndpoint];

    NSDictionary* parameters = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithUnsignedInt:userID], @"user_id",
                                token, @"authentication_token", nil];

    NSMutableURLRequest* friendsRequest = [NSMutableURLRequest postRequestWithURL:allFriendsURL];
    [friendsRequest setPostParameters:parameters];

    AFJSONRequestOperation* operation;
    operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:friendsRequest
                                                                success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
    {
        LogTrace(@"%@ response: %@", NSStringFromSelector(_cmd), JSON);
        if (success) {
            success(JSON);
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        LogError(@"%@ error :%@", NSStringFromSelector(_cmd), error);
        if (failure) {
            failure(request, response, error, JSON);
        }
    }];
    [operation start];
}

@end
