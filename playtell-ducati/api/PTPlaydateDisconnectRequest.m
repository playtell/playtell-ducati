//
//  PTPlaydateDisconnectRequest.m
//  playtell-ducati
//
//  Created by Dimitry Bentsionov on 6/6/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import "PTPlaydateDisconnectRequest.h"
#import "AFNetworking.h"
#import "NSMutableURLRequest+POSTParameters.h"

@implementation PTPlaydateDisconnectRequest

- (void)playdateDisconnectWithPlaydateId:(NSNumber*)playdateId
                               authToken:(NSString*)token
                               onSuccess:(PTPlaydateDisconnectRequestSuccessBlock)success
                               onFailure:(PTPlaydateDisconnectRequestFailureBlock)failure {
    
    NSDictionary* postParameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                    playdateId, @"playdate_id",
                                    token, @"authentication_token",
                                    nil];
    
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/api/playdate/disconnect.json", ROOT_URL]];
    NSMutableURLRequest* request = [NSMutableURLRequest postRequestWithURL:url];
    [request setPostParameters:postParameters];
    
    AFJSONRequestOperation* playdateDisconnect;
    playdateDisconnect = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
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
    [playdateDisconnect start];
}

@end
