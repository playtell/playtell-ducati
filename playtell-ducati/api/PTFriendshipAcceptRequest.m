//
//  PTFriendshipAcceptRequest.m
//  playtell-ducati
//
//  Created by Dimitry Bentsionov on 9/4/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import "PTFriendshipAcceptRequest.h"
#import "AFNetworking.h"
#import "NSMutableURLRequest+POSTParameters.h"

@implementation PTFriendshipAcceptRequest

- (void)acceptFriendshipWith:(NSInteger)userId
                   authToken:(NSString*)token
                     success:(PTFriendshipAcceptRequestSuccessBlock)success
                     failure:(PTFriendshipAcceptRequestFailureBlock)failure {
    
    NSDictionary* postParameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithInteger:userId], @"user_id",
                                    token, @"authentication_token",
                                    nil];
    
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/api/friendship/accept", ROOT_URL]];
    NSMutableURLRequest* request = [NSMutableURLRequest postRequestWithURL:url];
    [request setPostParameters:postParameters];
    
    AFJSONRequestOperation* acceptFriendship;
    acceptFriendship = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
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
    [acceptFriendship start];
}

@end