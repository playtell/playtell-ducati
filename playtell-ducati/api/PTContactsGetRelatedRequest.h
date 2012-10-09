//
//  PTContactsGetRelatedRequest.h
//  playtell-ducati
//
//  Created by Dimitry Bentsionov on 7/27/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import "PTRequest.h"

typedef void (^PTContactsGetRelatedRequestSuccessBlock) (NSArray* contacts, NSInteger total);
typedef void (^PTContactsGetRelatedRequestFailureBlock) (NSURLRequest* request, NSHTTPURLResponse* response, NSError* error, id JSON);

@interface PTContactsGetRelatedRequest : PTRequest

- (void)getRelatedWithAuthToken:(NSString*)token
                        success:(PTContactsGetRelatedRequestSuccessBlock)success
                        failure:(PTContactsGetRelatedRequestFailureBlock)failure;

@end