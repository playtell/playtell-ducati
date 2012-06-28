//
//  PTUsersGetStatusRequest.m
//  playtell-ducati
//
//  Created by Dimitry Bentsionov on 6/28/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import "PTUsersGetStatusRequest.h"
#import "AFNetworking.h"
#import "NSMutableURLRequest+POSTParameters.h"

@implementation PTUsersGetStatusRequest

- (void)usersGetStatusForUserIds:(NSArray *)userIds
                       authToken:(NSString*)token
                         success:(PTUsersGetStatusRequestSuccessBlock)success
                         failure:(PTUsersGetStatusRequestFailureBlock)failure {
    
    NSString *concatUserIds = [userIds componentsJoinedByString:@","];
    NSDictionary* postParameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                    concatUserIds, @"user_ids",
                                    token, @"authentication_token",
                                    nil];
    
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/api/users/get_status", ROOT_URL]];
    NSMutableURLRequest* request = [NSMutableURLRequest postRequestWithURL:url];
    [request setPostParameters:postParameters];
    
    AFJSONRequestOperation* usersGetStatus;
    usersGetStatus = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
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
    [usersGetStatus start];
}

@end
