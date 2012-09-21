//
//  PTGetSampleOpenTokToken.m
//  playtell-ducati
//
//  Created by Ricky Hussmann on 9/21/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import "AFNetworking.h"
#import "PTGetSampleOpenTokToken.h"

@implementation PTGetSampleOpenTokToken

const NSString* SESSION_KEY = @"session_id";
const NSString* TOKEN_KEY = @"token";

- (void)requestOpenTokSessionAndTokenWithSuccess:(PTGetOpenTokSessionSuccessBlock)success
                                         failure:(PTGetOpenTokSessionFailureBlock)failure {

    NSURLRequest* request = [NSURLRequest requestWithURL:[self getTokenURL]];
    AFJSONRequestOperation* op = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
                                                                                 success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
    {
        if (success) {
            NSString* session = [JSON valueForKey:(NSString*)SESSION_KEY];
            NSString* token = [JSON valueForKey:(NSString*)TOKEN_KEY];
            success(session, token);
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        if (failure) {
            failure(request, response, error, JSON);
        }
    }];
    [op start];
}

- (NSURL*)getTokenURL {
    NSString* getTokenURLString = [NSString stringWithFormat:@"%@/api/playdate/generate_ot_session", ROOT_URL];
    return [NSURL URLWithString:getTokenURLString];
}

@end
