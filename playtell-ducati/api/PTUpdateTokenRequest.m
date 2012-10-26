//
//  PTUpdateTokenRequest.m
//  playtell-ducati
//
//  Created by Dimitry Bentsionov on 10/12/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import "PTUpdateTokenRequest.h"
#import "AFNetworking.h"
#import "NSDictionary+Util.h"
#import "NSMutableURLRequest+POSTParameters.h"

@implementation PTUpdateTokenRequest

- (void)updateTokenWithUAToken:(NSString*)uaToken
                       PTToken:(NSString*)ptToken
                     authToken:(NSString*)authToken
                     onSuccess:(PTUpdateTokenRequestSuccessBlock)success
                     onFailure:(PTUpdateTokenRequestFailureBlock)failure {
    
    NSString *version = [NSString stringWithFormat:@"%@", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]];

    NSDictionary* postParameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                    authToken, @"authentication_token",
                                    uaToken, @"UA_token",
                                    ptToken, @"PT_token",
                                    version, @"version",
                                    nil];
    
    NSURL *tokenURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/api/token/update.json", ROOT_URL]];
    NSMutableURLRequest* request = [NSMutableURLRequest postRequestWithURL:tokenURL];
    [request setPostParameters:postParameters];
    
    AFJSONRequestOperation* updateToken;
    updateToken = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
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
    [updateToken start];
}

@end