//
//  PTUpdateSettingsRequest.h
//  playtell-ducati
//
//  Created by Ricky Hussmann on 6/1/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import "PTRequest.h"

typedef void (^PTUpdateSettingsRequestSuccessBlock) (NSDictionary* result);
typedef void (^PTUpdateSettingsRequestFailureBlock) (NSURLRequest* request, NSHTTPURLResponse* response, NSError* error, id JSON);

@interface PTUpdateSettingsRequest : PTRequest

- (void)udpateSettingsWithEmail:(NSString*)email
                       password:(NSString*)password
           passwordConfirmation:(NSString*)confirmation
                      authToken:(NSString*)token
                      onSuccess:(PTUpdateSettingsRequestSuccessBlock)success
                      onFailure:(PTUpdateSettingsRequestFailureBlock)failure;

@end
