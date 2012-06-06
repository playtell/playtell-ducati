//
//  PTBookCloseRequest.h
//  playtell-ducati
//
//  Created by Dimitry Bentsionov on 6/6/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import "PTRequest.h"

typedef void (^PTBookCloseRequestSuccessBlock) (NSDictionary* result);
typedef void (^PTBookCloseRequestFailureBlock) (NSURLRequest* request, NSHTTPURLResponse* response, NSError* error, id JSON);

@interface PTBookCloseRequest : PTRequest

- (void)closeBookWithPlaydateId:(NSNumber*)playdateId
                         bookId:(NSNumber*)bookId
                      authToken:(NSString*)token
                      onSuccess:(PTBookCloseRequestSuccessBlock)success
                      onFailure:(PTBookCloseRequestFailureBlock)failure;

@end
