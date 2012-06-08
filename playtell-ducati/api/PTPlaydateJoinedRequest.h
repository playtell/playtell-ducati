//
//  PTPlaydateJoinedRequest.h
//  playtell-ducati
//
//  Created by Dimitry Bentsionov on 6/7/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import "PTRequest.h"

typedef void (^PTPlaydateJoinedRequestSuccessBlock) (NSDictionary* result);
typedef void (^PTPlaydateJoinedRequestFailureBlock) (NSURLRequest* request, NSHTTPURLResponse* response, NSError* error, id JSON);

@interface PTPlaydateJoinedRequest : PTRequest

- (void)playdateJoinedWithPlaydate:(NSNumber*)playdateId
                         authToken:(NSString*)token
                         onSuccess:(PTPlaydateJoinedRequestSuccessBlock)success
                         onFailure:(PTPlaydateJoinedRequestFailureBlock)failure;

@end
