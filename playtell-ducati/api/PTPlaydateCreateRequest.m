//
//  PTPlaydateCreateRequest.m
//  playtell-ducati
//
//  Created by Dimitry Bentsionov on 6/6/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import "PTPlaydateCreateRequest.h"
#import "AFNetworking.h"
#import "NSMutableURLRequest+POSTParameters.h"

@implementation PTPlaydateCreateRequest

- (void)playdateCreateWithFriend:(NSNumber*)friendId
                       authToken:(NSString*)token
                       onSuccess:(PTPlaydateCreateRequestSuccessBlock)success
                       onFailure:(PTPlaydateCreateRequestFailureBlock)failure {
    
    NSDictionary* postParameters = [NSDictionary dictionaryWithObjectsAndKeys:friendId, @"friend_id", token, @"authentication_token", nil];
    
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/api/playdate/create.json", ROOT_URL]];
    NSMutableURLRequest* request = [NSMutableURLRequest postRequestWithURL:url];
    [request setPostParameters:postParameters];
    
    AFJSONRequestOperation* playdateCreate;
    playdateCreate = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
                                                               success:^(NSURLRequest *request,
                                                                         NSHTTPURLResponse *response,
                                                                         id JSON)
                {
                    if (success != nil) {
                        success(JSON);
                    }
                } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                    if (failure != nil) {
                        failure(request, response, error, JSON);
                    }
                }];
    [playdateCreate start];
}

@end
