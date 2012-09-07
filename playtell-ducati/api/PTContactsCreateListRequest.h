//
//  PTContactsCreateListRequest.h
//  playtell-ducati
//
//  Created by Dimitry Bentsionov on 7/17/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import "PTRequest.h"

typedef void (^PTContactsCreateListRequestSuccessBlock) (NSDictionary* result);
typedef void (^PTContactsCreateListRequestFailureBlock) (NSURLRequest* request, NSHTTPURLResponse* response, NSError* error, id JSON);

@interface PTContactsCreateListRequest : PTRequest

- (void)createList:(NSMutableArray *)contacts
         authToken:(NSString*)token
           success:(PTContactsCreateListRequestSuccessBlock)success
           failure:(PTContactsCreateListRequestFailureBlock)failure;

@end
