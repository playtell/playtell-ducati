//
//  PTVersionCheckRequest.m
//  playtell-ducati
//
//  Created by Dimitry Bentsionov on 12/11/12.
//  Copyright (c) 2012 PlayTell. All rights reserved.
//

#import "PTVersionCheckRequest.h"
#import "AFNetworking.h"
#import "NSDictionary+Util.h"
#import "NSMutableURLRequest+POSTParameters.h"

@implementation PTVersionCheckRequest

- (void)checkVersion:(PTVersionCheckRequestSuccessBlock)success
           onFailure:(PTVersionCheckRequestFailureBlock)failure {
    
    NSString *version = [NSString stringWithFormat:@"%@", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]];
    
    NSDictionary* postParameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                    version, @"version",
                                    nil];
    
    NSURL *tokenURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/api/settings/version_check.json", ROOT_URL]];
    NSMutableURLRequest* request = [NSMutableURLRequest postRequestWithURL:tokenURL];
    [request setPostParameters:postParameters];
    
    AFJSONRequestOperation* versionCheck;
    versionCheck = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
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
    [versionCheck start];
}

@end