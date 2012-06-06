//
//  PTBookChangeRequest.h
//  playtell-ducati
//
//  Created by Dimitry Bentsionov on 6/6/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import "PTRequest.h"

typedef void (^PTBookChangeRequestSuccessBlock) (NSDictionary* result);
typedef void (^PTBookChangeRequestFailureBlock) (NSURLRequest* request, NSHTTPURLResponse* response, NSError* error, id JSON);

@interface PTBookChangeRequest : PTRequest

- (void)changeBookWithPlaydateId:(NSNumber*)playdateId
                          bookId:(NSNumber*)bookId
                      pageNumber:(NSNumber*)pageNum
                       authToken:(NSString*)token
                       onSuccess:(PTBookChangeRequestSuccessBlock)success
                       onFailure:(PTBookChangeRequestFailureBlock)failure;

@end
