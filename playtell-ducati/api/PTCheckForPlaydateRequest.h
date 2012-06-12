//
//  PTCheckForPlaydateRequest.h
//  playtell-ducati
//
//  Created by Ricky Hussmann on 6/11/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import "PTPlaymateFactory.h"
#import "PTPlaydate.h"
#import "PTRequest.h"

typedef void (^PTCheckForPlaydateRequestSuccessBlock) (PTPlaydate* result);
typedef void (^PTCheckForPlaydateRequestFailureBlock) (NSURLRequest* request, NSHTTPURLResponse* response, NSError* error, id JSON);

@interface PTCheckForPlaydateRequest : PTRequest

- (void)checkForExistingPlaydateForUser:(NSUInteger)userID
                              authToken:(NSString*)token
                        playmateFactory:(id<PTPlaymateFactory>)factory
                                success:(PTCheckForPlaydateRequestSuccessBlock)success
                                failure:(PTCheckForPlaydateRequestFailureBlock)failure;

@end
