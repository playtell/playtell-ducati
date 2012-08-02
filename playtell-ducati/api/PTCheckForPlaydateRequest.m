//
//  PTCheckForPlaydateRequest.m
//  playtell-ducati
//
//  Created by Ricky Hussmann on 6/11/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import "AFNetworking.h"
#import "Logging.h"
#import "PTCheckForPlaydateRequest.h"

#import "NSMutableURLRequest+POSTParameters.h"

@implementation PTCheckForPlaydateRequest

- (void)checkForExistingPlaydateForUser:(NSUInteger)userID
                              authToken:(NSString*)token
                        playmateFactory:(id<PTPlaymateFactory>)factory
                                success:(PTCheckForPlaydateRequestSuccessBlock)success
                                failure:(PTCheckForPlaydateRequestFailureBlock)failure {

    NSDictionary* postParameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithUnsignedInt:userID], @"user_id",
                                    token, @"authentication_token",
                                    nil];
    
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/api/playdate/check_for_playdate.json", ROOT_URL]];
    NSMutableURLRequest* request = [NSMutableURLRequest postRequestWithURL:url];
    [request setPostParameters:postParameters];
    
    AFJSONRequestOperation* checkForPlaydate;
    checkForPlaydate = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
                                                                       success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
    {
        LogTrace(@"%@: %@", NSStringFromSelector(_cmd), JSON);
        PTPlaydate* playdate = [[PTPlaydate alloc] initWithDictionary:JSON
                                                      playmateFactory:factory];
        if (success) {
            success(playdate);
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        LogError(@"%@ error: %@", NSStringFromSelector(_cmd), error);
        if (failure) {
            failure(request, response, error, JSON);
        }
    }];
    [checkForPlaydate start];
}

@end
