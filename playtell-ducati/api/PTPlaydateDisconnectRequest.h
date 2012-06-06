//
//  PTPlaydateDisconnectRequest.h
//  playtell-ducati
//
//  Created by Dimitry Bentsionov on 6/6/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import "PTRequest.h"

typedef void (^PTPlaydateDisconnectRequestSuccessBlock) (NSDictionary* result);
typedef void (^PTPlaydateDisconnectRequestFailureBlock) (NSURLRequest* request, NSHTTPURLResponse* response, NSError* error, id JSON);

@interface PTPlaydateDisconnectRequest : PTRequest

- (void)playdateDisconnectWithPlaydateId:(NSNumber*)playdateId
                               authToken:(NSString*)token
                               onSuccess:(PTPlaydateDisconnectRequestSuccessBlock)success
                               onFailure:(PTPlaydateDisconnectRequestFailureBlock)failure;

@end
