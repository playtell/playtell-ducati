//
//  PTLoginRequest.m
//  playtell-ducati
//
//  Created by Ricky Hussmann on 6/1/12.
//  Copyright (c) 2012 PlayTell. All rights reserved.
//

#import "AFNetworking.h"
#import "PTLoginRequest.h"

#import "NSDictionary+Util.h"
#import "NSMutableURLRequest+POSTParameters.h"

@implementation PTLoginRequest

- (void)loginWithUsername:(NSString*)username
                 password:(NSString*)password
                pushToken:(NSString*)pushToken
                onSuccess:(PTLoginRequestSuccessBlock)success
                onFailure:(PTLoginRequestFailureBlock)failure {

    NSDictionary* postParameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                    username, @"email",
                                    password, @"password",
                                    pushToken, @"device_token",
                                    nil];

    NSURL *tokenURL = [NSURL URLWithString:[self authTokenURL]];
    NSMutableURLRequest* request = [NSMutableURLRequest postRequestWithURL:tokenURL];
    [request setPostParameters:postParameters];

    [[AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request,
                                                                               NSHTTPURLResponse *response,
                                                                               id JSON)
      {
          NSLog(@"Login success: %@", JSON);
          if (![JSON containsKey:@"token"]) {

              // TODO: Need to figure out the right information to pass around into the
              // failure block
              NSDictionary *errorDict = [NSDictionary dictionaryWithObject:[JSON valueForKey:@"message"]
                                                                    forKey:NSLocalizedDescriptionKey];
              NSError* anError = [NSError errorWithDomain:@"PTLoginDomain"
                                                     code:0
                                                 userInfo:errorDict];
              failure(request, response, anError, JSON);
              return;
          } else {
              success(JSON);
          }
      } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
          NSLog(@"Login failure");
          NSLog(@"Request: %@, Response: %@, Error: %@, JSON: %@", request, response, error, JSON);

          NSError* loginError = error;
          if (![JSON containsKey:@"token"]) {
              
              // TODO: Need to figure out the right information to pass around into the
              // failure block
              NSDictionary *errorDict = [NSDictionary dictionaryWithObject:[JSON valueForKey:@"message"]
                                                                    forKey:NSLocalizedDescriptionKey];
              loginError =  [NSError errorWithDomain:@"PTLoginDomain"
                                                code:0
                                            userInfo:errorDict];
          }
          failure(request, response, loginError, JSON);
      }] start];
}

- (NSString*)authTokenURL {
    return [NSString stringWithFormat:@"%@/api/tokens.json", ROOT_URL];
}

@end
