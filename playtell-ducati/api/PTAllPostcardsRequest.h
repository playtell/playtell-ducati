//
//  PTAllPostcardsRequest.h
//  playtell-ducati
//
//  Created by Adam Horne on 11/27/12.
//  Copyright (c) 2012 PlayTell. All rights reserved.
//

#import "PTRequest.h"

typedef void (^PTAllPostcardsRequestSuccessBlock) (NSArray* result);
typedef void (^PTAllPostcardsRequestFailureBlock) (NSURLRequest* request, NSHTTPURLResponse* response, NSError* error, id JSON);

@interface PTAllPostcardsRequest : PTRequest

- (void)allPostcardsWithUserID:(NSUInteger)userID
                       success:(PTAllPostcardsRequestSuccessBlock)success
                       failure:(PTAllPostcardsRequestFailureBlock)failure;

@end
