//
//  PTPlaydateCreateRequest.h
//  playtell-ducati
//
//  Created by Dimitry Bentsionov on 6/6/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import "PTRequest.h"

typedef void (^PTPlaydateCreateRequestSuccessBlock) (NSDictionary* result);
typedef void (^PTPlaydateCreateRequestFailureBlock) (NSURLRequest* request, NSHTTPURLResponse* response, NSError* error, id JSON);

@interface PTPlaydateCreateRequest : PTRequest

- (void)playdateCreateWithFriend:(NSNumber*)friendId
                       authToken:(NSString*)token
                       onSuccess:(PTPlaydateCreateRequestSuccessBlock)success
                       onFailure:(PTPlaydateCreateRequestFailureBlock)failure;

@end
