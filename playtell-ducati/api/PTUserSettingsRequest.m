//
//  PTUserSettingsRequest.m
//  playtell-ducati
//
//  Created by Adam Horne on 2/21/13.
//  Copyright (c) 2013 PlayTell. All rights reserved.
//

#import "AFNetworking.h"
#import "Logging.h"
#import "PTUserSettingsRequest.h"

#import "NSMutableURLRequest+POSTParameters.h"

@implementation PTUserSettingsRequest

- (void)getUserSettingsWithUserId:(NSInteger)userId
                        authToken:(NSString *)token
                          success:(PTUserSettingsRequestSuccessBlock)success
                          failure:(PTUserSettingsRequestFailureBlock)failure {
    NSDictionary* postParameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                    token, @"authentication_token",
                                    [NSNumber numberWithInteger:userId], @"user_id",
                                    nil];
    
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/api/users/show.json", ROOT_URL]];
    NSMutableURLRequest* request = [NSMutableURLRequest postRequestWithURL:url];
    [request setPostParameters:postParameters];
    
    AFJSONRequestOperation* changePassword;
    changePassword = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
                                                                     success:^(NSURLRequest *request,
                                                                               NSHTTPURLResponse *response,
                                                                               id JSON)
                      {
                          LogTrace(@"Get user settings success: %@", JSON);
                          success(JSON);
                      } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                          LogError(@"Get user settings failure: %@", error);
                          failure(request, response, error, JSON);
                      }];
    [changePassword start];
}

@end
