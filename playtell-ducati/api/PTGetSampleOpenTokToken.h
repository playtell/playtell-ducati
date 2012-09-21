//
//  PTGetSampleOpenTokToken.h
//  playtell-ducati
//
//  Created by Ricky Hussmann on 9/21/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import "PTRequest.h"
typedef void (^PTGetOpenTokSessionSuccessBlock) (NSString* openTokSession, NSString* openTokToken);
typedef void (^PTGetOpenTokSessionFailureBlock) (NSURLRequest* request, NSHTTPURLResponse* response, NSError* error, id JSON);

@interface PTGetSampleOpenTokToken : PTRequest

- (void)requestOpenTokSessionAndTokenWithSuccess:(PTGetOpenTokSessionSuccessBlock)success
                                         failure:(PTGetOpenTokSessionFailureBlock)failure;

@end
