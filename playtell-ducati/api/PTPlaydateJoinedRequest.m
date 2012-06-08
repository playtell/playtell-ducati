//
//  PTPlaydateJoinedRequest.m
//  playtell-ducati
//
//  Created by Dimitry Bentsionov on 6/7/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import "PTPlaydateJoinedRequest.h"
#import "AFNetworking.h"
#import "NSMutableURLRequest+POSTParameters.h"

@implementation PTPlaydateJoinedRequest

- (void)playdateJoinedWithPlaydate:(NSNumber*)playdateId
                         authToken:(NSString*)token
                         onSuccess:(PTPlaydateJoinedRequestSuccessBlock)success
                         onFailure:(PTPlaydateJoinedRequestFailureBlock)failure {
    
    NSDictionary* postParameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                    playdateId, @"playdate_id",
                                    token, @"authentication_token",
                                    nil];
    
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/api/playdate/join.json", ROOT_URL]];
    NSMutableURLRequest* request = [NSMutableURLRequest postRequestWithURL:url];
    [request setPostParameters:postParameters];
    
    AFJSONRequestOperation* playdateJoined;
    playdateJoined = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
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
    [playdateJoined start];
}

@end
