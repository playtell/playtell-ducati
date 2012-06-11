//
//  PTPlaydateFingerTapRequest.h
//  playtell-ducati
//
//  Created by Dimitry Bentsionov on 6/11/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import "PTRequest.h"

typedef void (^PTPlaydateFingerTapRequestSuccessBlock) (NSDictionary* result);
typedef void (^PTPlaydateFingerTapRequestFailureBlock) (NSURLRequest* request, NSHTTPURLResponse* response, NSError* error, id JSON);

@interface PTPlaydateFingerTapRequest : PTRequest

- (void)playdateFingerTapWithPlaydateId:(NSNumber*)playdateId
                                  point:(CGPoint)point
                              authToken:(NSString*)token
                              onSuccess:(PTPlaydateFingerTapRequestSuccessBlock)success
                              onFailure:(PTPlaydateFingerTapRequestFailureBlock)failure;

@end
