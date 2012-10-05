//
//  PTUserEmailCheckRequest.h
//  playtell-ducati
//
//  Created by Dimitry Bentsionov on 9/19/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import "PTRequest.h"

typedef void (^PTUserEmailCheckRequestSuccessBlock) (NSDictionary* result);
typedef void (^PTUserEmailCheckRequestFailureBlock) (NSURLRequest* request, NSHTTPURLResponse* response, NSError* error, id JSON);

@interface PTUserEmailCheckRequest : PTRequest

- (void)checkEmail:(NSString *)email
           success:(PTUserEmailCheckRequestSuccessBlock)success
           failure:(PTUserEmailCheckRequestFailureBlock)failure;

@end