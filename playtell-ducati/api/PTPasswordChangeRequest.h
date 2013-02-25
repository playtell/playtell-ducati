//
//  PTPasswordChangeRequest.h
//  playtell-ducati
//
//  Created by Adam Horne on 2/8/13.
//  Copyright (c) 2013 PlayTell. All rights reserved.
//

#import "PTRequest.h"

typedef void (^PTPasswordChangeRequestSuccessBlock) (NSDictionary* result);
typedef void (^PTPasswordChangeRequestFailureBlock) (NSURLRequest* request, NSHTTPURLResponse* response, NSError* error, id JSON);

@interface PTPasswordChangeRequest : PTRequest

- (void)changePasswordTo:(NSString *)password
     withCurrentPassword:(NSString *)currentPassword
                  userId:(NSInteger)userId
               authToken:(NSString *)token
               onSuccess:(PTPasswordChangeRequestSuccessBlock)success
               onFailure:(PTPasswordChangeRequestFailureBlock)failure;

@end
