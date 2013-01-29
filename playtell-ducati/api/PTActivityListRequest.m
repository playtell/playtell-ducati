//
//  PTActivityListRequest.m
//  playtell-ducati
//
//  Created by Adam Horne on 1/17/13.
//  Copyright (c) 2013 PlayTell. All rights reserved.
//

#import "PTActivityListRequest.h"
#import "AFNetworking.h"
#import "NSMutableURLRequest+POSTParameters.h"

@implementation PTActivityListRequest

- (void)activityListWithAuthToken:(NSString*)token
                        onSuccess:(PTActivityListRequestSuccessBlock)success
                        onFailure:(PTActivityListRequestFailureBlock)failure {
    
    NSDictionary* postParameters = [NSDictionary dictionaryWithObjectsAndKeys:token, @"authentication_token", nil];
    
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/api/activities/list.json", ROOT_URL]];
    NSMutableURLRequest* request = [NSMutableURLRequest postRequestWithURL:url];
    [request setPostParameters:postParameters];
    
    AFJSONRequestOperation* booksList;
    booksList = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
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
    [booksList start];
}

@end
