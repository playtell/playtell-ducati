//
//  PTPlaydateDetailsRequest.m
//  playtell-ducati
//
//  Created by Dimitry Bentsionov on 6/19/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import "PTPlaydateDetailsRequest.h"
#import "AFNetworking.h"
#import "NSMutableURLRequest+POSTParameters.h"

@implementation PTPlaydateDetailsRequest

- (void)playdateDetailsForPlaydateId:(NSInteger)playdateId
                           authToken:(NSString*)token
                     playmateFactory:(id<PTPlaymateFactory>)factory
                             success:(PTPlaydateDetailsRequestSuccessBlock)success
                             failure:(PTPlaydateDetailsRequestFailureBlock)failure {
    
    NSDictionary* postParameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithInteger:playdateId], @"playdate_id",
                                    token, @"authentication_token",
                                    nil];
    
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/api/playdate/details", ROOT_URL]];
    NSMutableURLRequest* request = [NSMutableURLRequest postRequestWithURL:url];
    [request setPostParameters:postParameters];
    
    AFJSONRequestOperation* playdateDetails;
    playdateDetails = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
                                                                       success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
                        {
                            PTPlaydate* playdate = [[PTPlaydate alloc] initWithDictionary:JSON
                                                                          playmateFactory:factory];
                            if (success) {
                                success(playdate);
                            }
                        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                            if (failure) {
                                failure(request, response, error, JSON);
                            }
                        }];
    [playdateDetails start];
}

@end
