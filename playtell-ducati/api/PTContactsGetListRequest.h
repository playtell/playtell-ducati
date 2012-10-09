//
//  PTContactsGetListRequest.h
//  playtell-ducati
//
//  Created by Dimitry Bentsionov on 7/17/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import "PTRequest.h"

typedef void (^PTContactsGetListRequestSuccessBlock) (NSArray* contacts, NSInteger total);
typedef void (^PTContactsGetListRequestFailureBlock) (NSURLRequest* request, NSHTTPURLResponse* response, NSError* error, id JSON);

@interface PTContactsGetListRequest : PTRequest

- (void)getListWithAuthToken:(NSString*)token
                     success:(PTContactsGetListRequestSuccessBlock)success
                     failure:(PTContactsGetListRequestFailureBlock)failure;

@end
