//
//  PTUpdateSettingsRequest.h
//  playtell-ducati
//
//  Created by Ricky Hussmann on 6/1/12.
//  Copyright (c) 2012 PlayTell. All rights reserved.
//

#import "PTRequest.h"

typedef void (^PTUpdateSettingsRequestSuccessBlock) (NSDictionary* result);
typedef void (^PTUpdateSettingsRequestFailureBlock) (NSURLRequest* request, NSHTTPURLResponse* response, NSError* error, id JSON);

@interface PTUpdateSettingsRequest : PTRequest

- (void)updateSettingsWithUserId:(NSInteger)userId
                           email:(NSString *)email
                        username:(NSString *)username
                        birthday:(NSDate *)birthday
                       authToken:(NSString *)token
                       onSuccess:(PTUpdateSettingsRequestSuccessBlock)success
                       onFailure:(PTUpdateSettingsRequestFailureBlock)failure;

@end
