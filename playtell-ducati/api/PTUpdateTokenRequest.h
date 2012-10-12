//
//  PTUpdateTokenRequest.h
//  playtell-ducati
//
//  Created by Dimitry Bentsionov on 10/12/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import "PTRequest.h"

typedef void (^PTUpdateTokenRequestSuccessBlock) (NSDictionary* result);
typedef void (^PTUpdateTokenRequestFailureBlock) (NSURLRequest* request, NSHTTPURLResponse* response, NSError* error, id JSON);

@interface PTUpdateTokenRequest : PTRequest

- (void)updateTokenWithToken:(NSString*)pushToken
                   authToken:(NSString*)authToken
                   onSuccess:(PTUpdateTokenRequestSuccessBlock)success
                   onFailure:(PTUpdateTokenRequestFailureBlock)failure;

@end
