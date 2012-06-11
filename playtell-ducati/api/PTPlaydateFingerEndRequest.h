//
//  PTPlaydateFingerEndRequest.h
//  playtell-ducati
//
//  Created by Dimitry Bentsionov on 6/11/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import "PTRequest.h"

typedef void (^PTPlaydateFingerEndRequestSuccessBlock) (NSDictionary* result);
typedef void (^PTPlaydateFingerEndRequestFailureBlock) (NSURLRequest* request, NSHTTPURLResponse* response, NSError* error, id JSON);

@interface PTPlaydateFingerEndRequest : PTRequest

- (void)playdateFingerEndWithPlaydateId:(NSNumber*)playdateId
                                  point:(CGPoint)point
                              authToken:(NSString*)token
                              onSuccess:(PTPlaydateFingerEndRequestSuccessBlock)success
                              onFailure:(PTPlaydateFingerEndRequestFailureBlock)failure;

@end
