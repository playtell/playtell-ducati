//
//  PTActivityListRequest.h
//  playtell-ducati
//
//  Created by Adam Horne on 1/17/13.
//  Copyright (c) 2013 PlayTell. All rights reserved.
//

#import "PTRequest.h"

typedef void (^PTActivityListRequestSuccessBlock) (NSDictionary* result);
typedef void (^PTActivityListRequestFailureBlock) (NSURLRequest* request, NSHTTPURLResponse* response, NSError* error, id JSON);

@interface PTActivityListRequest : PTRequest

- (void)activityListWithAuthToken:(NSString*)token
                        onSuccess:(PTActivityListRequestSuccessBlock)success
                        onFailure:(PTActivityListRequestFailureBlock)failure;

@end
