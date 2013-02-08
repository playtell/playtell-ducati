//
//  PTPasswordChangeRequest.m
//  playtell-ducati
//
//  Created by Adam Horne on 2/8/13.
//  Copyright (c) 2013 PlayTell. All rights reserved.
//

#import "AFNetworking.h"
#import "Logging.h"
#import "PTPasswordChangeRequest.h"

#import "NSMutableURLRequest+POSTParameters.h"

@implementation PTPasswordChangeRequest

- (void)changePasswordTo:(NSString *)password
     withCurrentPassword:(NSString *)currentPassword
                  userId:(NSInteger)userId
               authToken:(NSString *)token
               onSuccess:(PTPasswordChangeRequestSuccessBlock)success
               onFailure:(PTPasswordChangeRequestFailureBlock)failure {
    NSDictionary* postParameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                    token, @"authentication_token",
                                    [NSNumber numberWithInteger:userId], @"user_id",
                                    password, @"user[password]",
                                    currentPassword, @"user[current_password]",
                                    nil];
    
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/api/users/change_password.json", ROOT_URL]];
    NSMutableURLRequest* request = [NSMutableURLRequest postRequestWithURL:url];
    [request setPostParameters:postParameters];
    
    AFJSONRequestOperation* changePassword;
    changePassword = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
                                                                     success:^(NSURLRequest *request,
                                                                               NSHTTPURLResponse *response,
                                                                               id JSON)
                      {
                          LogTrace(@"Change password success: %@", JSON);
                          success(JSON);
                      } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                          LogError(@"Change password failure: %@", error);
                          failure(request, response, error, JSON);
                      }];
    [changePassword start];
}

@end
