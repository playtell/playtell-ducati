//
//  PTNumNewPostcardsRequest.h
//  playtell-ducati
//
//  Created by Adam Horne on 11/27/12.
//  Copyright (c) 2012 PlayTell. All rights reserved.
//

#import "PTRequest.h"

typedef void (^PTNumNewPostcardsRequestSuccessBlock) (NSDictionary* result);
typedef void (^PTNumNewPostcardsRequestFailureBlock) (NSURLRequest* request, NSHTTPURLResponse* response, NSError* error, id JSON);

@interface PTNumNewPostcardsRequest : PTRequest

- (void)numNewPostcardsWithUserID:(NSUInteger)userID
                          success:(PTNumNewPostcardsRequestSuccessBlock)success
                          failure:(PTNumNewPostcardsRequestFailureBlock)failure;

@end
