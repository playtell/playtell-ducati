//
//  PTMemoryNewGameRequest.h
//  playtell-ducati
//
//  Created by Giancarlo D on 9/5/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import "PTRequest.h"

typedef void (^PTMemoryNewGameRequestSuccessBlock) (NSDictionary* result);
typedef void (^PTMemoryNewGameRequestFailureBlock) (NSURLRequest* request, NSHTTPURLResponse* response, NSError* error, id JSON);

@interface PTMemoryNewGameRequest : PTRequest

- (void)newBoardWithPlaydateId:(NSNumber*)playdateId
                     authToken:(NSString*)token
                   playmate_id:(NSString *)playmate_id
                   initiatorId:(NSString *)initiator_id
                     onSuccess:(PTMemoryNewGameRequestSuccessBlock)success
                       theme_ID:(NSString *)theme_id
               num_total_cards:(NSString *)num_total_cards
                     onFailure:(PTMemoryNewGameRequestFailureBlock)failure;

@end