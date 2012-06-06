//
//  PTPageTurnRequest.m
//  playtell-ducati
//
//  Created by Dimitry Bentsionov on 6/6/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import "PTPageTurnRequest.h"
#import "AFNetworking.h"
#import "NSMutableURLRequest+POSTParameters.h"

@implementation PTPageTurnRequest

- (void)pageTurnWithPlaydateId:(NSNumber*)playdateId
                    pageNumber:(NSNumber*)pageNum
                     authToken:(NSString*)token
                     onSuccess:(PTPageTurnRequestSuccessBlock)success
                     onFailure:(PTPageTurnRequestFailureBlock)failure {
    
    NSDictionary* postParameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                    playdateId, @"playdate_id",
                                    pageNum, @"new_page_num",
                                    token, @"authentication_token",
                                    nil];
    
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/api/playdate/turn_page.json", ROOT_URL]];
    NSMutableURLRequest* request = [NSMutableURLRequest postRequestWithURL:url];
    [request setPostParameters:postParameters];
    
    AFJSONRequestOperation* pageTurn;
    pageTurn = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
                                                                success:^(NSURLRequest *request,
                                                                          NSHTTPURLResponse *response,
                                                                          id JSON)
                 {
                     success(JSON);
                 } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                     failure(request, response, error, JSON);
                 }];
    [pageTurn start];
}

@end
