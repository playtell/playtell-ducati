//
//  PTVersionCheckRequest.h
//  playtell-ducati
//
//  Created by Dimitry Bentsionov on 12/11/12.
//  Copyright (c) 2012 PlayTell. All rights reserved.
//

#import "PTRequest.h"

typedef void (^PTVersionCheckRequestSuccessBlock) (NSDictionary* result);
typedef void (^PTVersionCheckRequestFailureBlock) (NSURLRequest* request, NSHTTPURLResponse* response, NSError* error, id JSON);

@interface PTVersionCheckRequest : PTRequest

- (void)checkVersion:(PTVersionCheckRequestSuccessBlock)success
           onFailure:(PTVersionCheckRequestFailureBlock)failure;

@end
