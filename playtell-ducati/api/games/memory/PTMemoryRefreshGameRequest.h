//
//  PTMemoryRefreshGameRequest.h
//  playtell-ducati
//
//  Created by Giancarlo D on 9/5/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import "PTRequest.h"

typedef void (^PTMemoryRefreshGameRequestSuccessBlock) (NSDictionary* result);
typedef void (^PTMemoryRefreshGameRequestFailureBlock) (NSURLRequest* request, NSHTTPURLResponse* response, NSError* error, id JSON);

@interface PTMemoryRefreshGameRequest : PTRequest

- (void)refreshBoardWithPlaydateId:(NSNumber*)playdate_id
                         authToken:(NSString*)token
                       playmate_id:(NSString *)playmate_id
                       initiatorId:(NSString *)initiator_id
                         onSuccess:(PTMemoryRefreshGameRequestSuccessBlock)success
                          theme_ID:(NSString *)theme_id
                   num_total_cards:(NSString *)num_total_cards
                   already_playing:(NSString *)already_playing
                         onFailure:(PTMemoryRefreshGameRequestFailureBlock)failure;

@end
