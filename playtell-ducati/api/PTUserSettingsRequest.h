//
//  PTUserSettingsRequest.h
//  playtell-ducati
//
//  Created by Adam Horne on 2/21/13.
//  Copyright (c) 2013 PlayTell. All rights reserved.
//

#import "PTRequest.h"

typedef void (^PTUserSettingsRequestSuccessBlock) (NSDictionary* result);
typedef void (^PTUserSettingsRequestFailureBlock) (NSURLRequest* request, NSHTTPURLResponse* response, NSError* error, id JSON);

@interface PTUserSettingsRequest : PTRequest

- (void)getUserSettingsWithUserId:(NSInteger)userId
                        authToken:(NSString *)token
                          success:(PTUserSettingsRequestSuccessBlock)success
                          failure:(PTUserSettingsRequestFailureBlock)failure;

@end
