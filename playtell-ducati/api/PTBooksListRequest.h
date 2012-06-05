//
//  PTBooksListRequest.h
//  playtell-ducati
//
//  Created by Dimitry Bentsionov on 6/5/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import "PTRequest.h"

typedef void (^PTBooksListRequestSuccessBlock) (NSDictionary* result);
typedef void (^PTBooksListRequestFailureBlock) (NSURLRequest* request, NSHTTPURLResponse* response, NSError* error, id JSON);

@interface PTBooksListRequest : PTRequest

- (void)booksListWithAuthToken:(NSString*)token
                     onSuccess:(PTBooksListRequestSuccessBlock)success
                     onFailure:(PTBooksListRequestFailureBlock)failure;
@end
