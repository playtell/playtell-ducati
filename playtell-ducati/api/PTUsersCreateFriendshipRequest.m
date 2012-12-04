//
//  PTUsersCreateFriendship.m
//  playtell-ducati
//
//  Created by Dimitry Bentsionov on 8/9/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import "PTUsersCreateFriendshipRequest.h"
#import "AFNetworking.h"
#import "NSMutableURLRequest+POSTParameters.h"
#import "NSString+UrlEncode.h"

@implementation PTUsersCreateFriendshipRequest

- (void)userCreateFriendship:(NSInteger)user_id
                   authToken:(NSString *)token
                     success:(PTUsersCreateFriendshipRequestSuccessBlock)success
                     failure:(PTUsersCreateFriendshipRequestFailureBlock)failure {
    
    NSDictionary* postParameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSString stringWithFormat:@"%i", user_id], @"user_id",
                                    token, @"authentication_token",
                                    nil];
    
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/api/friendship/create", ROOT_URL]];
    NSMutableURLRequest* request = [NSMutableURLRequest postRequestWithURL:url];
    [request setPostParameters:postParameters];
    
    AFJSONRequestOperation* createFriendship;
    createFriendship = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
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
    [createFriendship start];
}

@end