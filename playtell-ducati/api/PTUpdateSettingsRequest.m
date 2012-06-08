//
//  PTUpdateSettingsRequest.m
//  playtell-ducati
//
//  Created by Ricky Hussmann on 6/1/12.
//  Copyright (c) 2012 PlayTell. All rights reserved.
//

#import "AFNetworking.h"
#import "Logging.h"
#import "PTUpdateSettingsRequest.h"

#import "NSMutableURLRequest+POSTParameters.h"

@implementation PTUpdateSettingsRequest


- (void)updateSettingsWithEmail:(NSString*)email
                       password:(NSString*)password
           passwordConfirmation:(NSString*)confirmation
                      authToken:(NSString*)token
                      onSuccess:(PTUpdateSettingsRequestSuccessBlock)success
                      onFailure:(PTUpdateSettingsRequestFailureBlock)failure {

    NSDictionary* postParameters = [NSDictionary dictionaryWithObjectsAndKeys:token, @"authentication_token",
                                    email, @"user[email]",
                                    password, @"user[password]",
                                    confirmation, @"user[password_confirmation]",
                                    nil];

    NSURL* url = [NSURL URLWithString:[self loginSettingsURL]];
    NSMutableURLRequest* request = [NSMutableURLRequest postRequestWithURL:url];
    [request setPostParameters:postParameters];

    AFJSONRequestOperation* updateSettings;
    updateSettings = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
                                                                     success:^(NSURLRequest *request,
                                                                               NSHTTPURLResponse *response,
                                                                               id JSON)
                      {
                          LogTrace(@"Update settings success: %@", JSON);
                          success(JSON);
                      } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                          LogError(@"Update settings failure: %@", error);
                          failure(request, response, error, JSON);
                      }];
    [updateSettings start];
}

- (NSString*)loginSettingsURL {
    return [NSString stringWithFormat:@"%@/api/update_settings.json", ROOT_URL];
}

@end
