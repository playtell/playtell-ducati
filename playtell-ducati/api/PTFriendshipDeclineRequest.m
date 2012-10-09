//
//  PTFriendshipDeclineRequest.m
//  playtell-ducati
//
//  Created by Dimitry Bentsionov on 9/4/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import "PTFriendshipDeclineRequest.h"
#import "AFNetworking.h"
#import "NSMutableURLRequest+POSTParameters.h"

@implementation PTFriendshipDeclineRequest

- (void)declineFriendshipFrom:(NSInteger)userId
                    authToken:(NSString*)token
                      success:(PTFriendshipDeclineRequestSuccessBlock)success
                      failure:(PTFriendshipDeclineRequestFailureBlock)failure {
    
    NSDictionary* postParameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithInteger:userId], @"user_id",
                                    token, @"authentication_token",
                                    nil];
    
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/api/friendship/decline", ROOT_URL]];
    NSMutableURLRequest* request = [NSMutableURLRequest postRequestWithURL:url];
    [request setPostParameters:postParameters];
    
    AFJSONRequestOperation* declineFriendship;
    declineFriendship = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
                                                                       success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
                        {
                            if (success) {
                                success(JSON);
                            }
                        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                            if (failure) {
                                failure(request, response, error, JSON);
                            }
                        }];
    [declineFriendship start];
}

@end