//
//  PTResetPasswordRequest.h
//  playtell-ducati
//
//  Created by Adam Horne on 3/15/13.
//  Copyright (c) 2013 PlayTell. All rights reserved.
//

#import "PTRequest.h"

typedef void (^PTResetPasswordRequestSuccessBlock) (NSDictionary* result);
typedef void (^PTResetPasswordRequestFailureBlock) (NSURLRequest* request, NSHTTPURLResponse* response, NSError* error, id JSON);

@interface PTResetPasswordRequest : PTRequest

- (void)resetPasswordForEmail:(NSString *)email
                    onSuccess:(PTResetPasswordRequestSuccessBlock)success
                    onFailure:(PTResetPasswordRequestFailureBlock)failure;

@end
