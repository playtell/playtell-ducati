//
//  PTUserEmailCheckRequest.m
//  playtell-ducati
//
//  Created by Dimitry Bentsionov on 9/19/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import "PTUserEmailCheckRequest.h"
#import "AFNetworking.h"
#import "NSMutableURLRequest+POSTParameters.h"
#import "NSString+UrlEncode.h"

@implementation PTUserEmailCheckRequest

- (void)checkEmail:(NSString *)email
           success:(PTUserEmailCheckRequestSuccessBlock)success
           failure:(PTUserEmailCheckRequestFailureBlock)failure {
    
    NSDictionary* postParameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                    email, @"email",
                                    nil];
    
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/api/users/email_check", ROOT_URL]];
    NSMutableURLRequest* request = [NSMutableURLRequest postRequestWithURL:url];
    [request setPostParameters:postParameters];
    
    AFJSONRequestOperation* emailCheck;
    emailCheck = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
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
    [emailCheck start];
}

- (void)checkEmail:(NSString *)email
        returnUser:(BOOL)returnUser
           success:(PTUserEmailCheckRequestSuccessBlock)success
           failure:(PTUserEmailCheckRequestFailureBlock)failure {
    
    NSDictionary* postParameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                    email, @"email",
                                    @"true", @"return_user",
                                    nil];
    
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/api/users/email_check", ROOT_URL]];
    NSMutableURLRequest* request = [NSMutableURLRequest postRequestWithURL:url];
    [request setPostParameters:postParameters];
    
    AFJSONRequestOperation* emailCheck;
    emailCheck = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
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
    [emailCheck start];
}

@end