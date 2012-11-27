//
//  PTPostcardCreateRequest.h
//  playtell-ducati
//
//  Created by Adam Horne on 11/27/12.
//  Copyright (c) 2012 PlayTell. All rights reserved.
//

#import "PTRequest.h"

typedef void (^PTPostcardCreateRequestSuccessBlock) (NSDictionary* result);
typedef void (^PTPostcardCreateRequestFailureBlock) (NSURLRequest* request, NSHTTPURLResponse* response, NSError* error, id JSON);

@interface PTPostcardCreateRequest : PTRequest

- (void)postcardCreateWithUserId:(NSInteger)senderId
                      playmateId:(NSInteger)receiverId
                           photo:(UIImage *)photo
                         success:(PTPostcardCreateRequestSuccessBlock)success
                         failure:(PTPostcardCreateRequestFailureBlock)failure;

@end
