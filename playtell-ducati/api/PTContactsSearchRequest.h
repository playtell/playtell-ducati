//
//  PTContactsSearchRequest.h
//  playtell-ducati
//
//  Created by Adam Horne on 1/28/13.
//  Copyright (c) 2013 PlayTell. All rights reserved.
//

#import "PTRequest.h"

typedef void (^PTContactsSearchRequestSuccessBlock) (NSArray* matches, NSString* searchString);
typedef void (^PTContactsSearchRequestFailureBlock) (NSURLRequest* request, NSHTTPURLResponse* response, NSError* error, id JSON);

@interface PTContactsSearchRequest : PTRequest

- (void)searchWithAuthToken:(NSString*)token
               searchString:(NSString *)searchString
                    success:(PTContactsSearchRequestSuccessBlock)success
                    failure:(PTContactsSearchRequestFailureBlock)failure;

@end
