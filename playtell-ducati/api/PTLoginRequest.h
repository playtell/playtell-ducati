//
//  PTLoginRequest.h
//  playtell-ducati
//
//  Created by Ricky Hussmann on 6/1/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import "PTRequest.h"

typedef void (^PTLoginRequestSuccessBlock) (NSDictionary* result);
typedef void (^PTLoginRequestFailureBlock) (NSURLRequest* request, NSHTTPURLResponse* response, NSError* error, id JSON);

@interface PTLoginRequest : PTRequest

- (void)loginWithUsername:(NSString*)username
                 password:(NSString*)password
                pushToken:(NSString*)pushToken
                onSuccess:(PTLoginRequestSuccessBlock)success
                onFailure:(PTLoginRequestFailureBlock)failure;

@end
