//
//  PTPlaydateFingerTapRequest.m
//  playtell-ducati
//
//  Created by Dimitry Bentsionov on 6/11/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import "PTPlaydateFingerTapRequest.h"
#import "AFNetworking.h"
#import "NSMutableURLRequest+POSTParameters.h"

@implementation PTPlaydateFingerTapRequest

- (void)playdateFingerTapWithPlaydateId:(NSNumber*)playdateId
                                  point:(CGPoint)point
                              authToken:(NSString*)token
                              onSuccess:(PTPlaydateFingerTapRequestSuccessBlock)success
                              onFailure:(PTPlaydateFingerTapRequestFailureBlock)failure {
    
    NSDictionary* postParameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                    playdateId, @"playdate_id",
                                    point.x, @"x",
                                    point.y, @"y",
                                    token, @"authentication_token",
                                    nil];
    
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/api/playdate/finger_tap.json", ROOT_URL]];
    NSMutableURLRequest* request = [NSMutableURLRequest postRequestWithURL:url];
    [request setPostParameters:postParameters];
    
    AFJSONRequestOperation* playdateFingerTap;
    playdateFingerTap = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
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
    [playdateFingerTap start];
}

@end
