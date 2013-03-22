//
//  PTResetPasswordRequest.m
//  playtell-ducati
//
//  Created by Adam Horne on 3/15/13.
//  Copyright (c) 2013 PlayTell. All rights reserved.
//

#import "AFNetworking.h"
#import "Logging.h"
#import "PTResetPasswordRequest.h"

#import "NSMutableURLRequest+POSTParameters.h"

@implementation PTResetPasswordRequest

- (void)resetPasswordForEmail:(NSString *)email
                    onSuccess:(PTResetPasswordRequestSuccessBlock)success
                    onFailure:(PTResetPasswordRequestFailureBlock)failure {
    
    NSDictionary* postParameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                    email, @"email",
                                    nil];
    
    NSURL *tokenURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/api/users/reset_password.json", ROOT_URL]];
    NSMutableURLRequest* request = [NSMutableURLRequest postRequestWithURL:tokenURL];
    [request setPostParameters:postParameters];
    
    [[AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request,
                                                                               NSHTTPURLResponse *response,
                                                                               id JSON)
      {
          LogTrace(@"Reset password success: %@", JSON);
          success(JSON);
      } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
          LogError(@"Login failure");
          LogError(@"Request: %@, Response: %@, Error: %@, JSON: %@", request, response, error, JSON);
          failure(request, response, error, JSON);
      }] start];
}

@end
