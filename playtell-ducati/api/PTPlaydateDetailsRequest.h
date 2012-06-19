//
//  PTPlaydateDetailsRequest.h
//  playtell-ducati
//
//  Created by Dimitry Bentsionov on 6/19/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import "PTRequest.h"
#import "PTPlaydate.h"
#import "PTRequest.h"

typedef void (^PTPlaydateDetailsRequestSuccessBlock) (PTPlaydate* result);
typedef void (^PTPlaydateDetailsRequestFailureBlock) (NSURLRequest* request, NSHTTPURLResponse* response, NSError* error, id JSON);

@interface PTPlaydateDetailsRequest : PTRequest

- (void)playdateDetailsForPlaydateId:(NSInteger)playdateId
                           authToken:(NSString*)token
                     playmateFactory:(id<PTPlaymateFactory>)factory
                             success:(PTPlaydateDetailsRequestSuccessBlock)success
                             failure:(PTPlaydateDetailsRequestFailureBlock)failure;

@end
