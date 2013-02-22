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

#import "NSDate+Rails.h"
#import "NSMutableURLRequest+POSTParameters.h"

@implementation PTUpdateSettingsRequest

- (void)updateSettingsWithUserId:(NSInteger)userId
                           email:(NSString *)email
                        username:(NSString *)username
                        birthday:(NSDate *)birthday
                       authToken:(NSString *)token
                       onSuccess:(PTUpdateSettingsRequestSuccessBlock)success
                       onFailure:(PTUpdateSettingsRequestFailureBlock)failure {
    
    NSMutableDictionary* postParameters = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                           token, @"authentication_token",
                                           [NSNumber numberWithInteger:userId], @"user_id",
                                           nil];
    
    if (email != nil) {
        [postParameters setObject:email forKey:@"user[email]"];
    }
    if (username != nil) {
        [postParameters setObject:username forKey:@"user[username]"];
    }
    if (birthday != nil) {
        [postParameters setObject:[birthday railsString] forKey:@"user[birthday]"];
    }
    
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/api/users/update.json", ROOT_URL]];
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

@end
