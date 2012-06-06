//
//  PTPageTurnRequest.h
//  playtell-ducati
//
//  Created by Dimitry Bentsionov on 6/6/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import "PTRequest.h"

typedef void (^PTPageTurnRequestSuccessBlock) (NSDictionary* result);
typedef void (^PTPageTurnRequestFailureBlock) (NSURLRequest* request, NSHTTPURLResponse* response, NSError* error, id JSON);

@interface PTPageTurnRequest : PTRequest

- (void)pageTurnWithPlaydateId:(NSNumber*)playdateId
                    pageNumber:(NSNumber*)pageNum
                     authToken:(NSString*)token
                     onSuccess:(PTPageTurnRequestSuccessBlock)success
                     onFailure:(PTPageTurnRequestFailureBlock)failure;

@end
