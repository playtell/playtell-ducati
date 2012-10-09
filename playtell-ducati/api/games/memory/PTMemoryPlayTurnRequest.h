//
//  PTMemoryPlayTurnRequest.h
//  playtell-ducati
//
//  Created by Giancarlo D on 9/5/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import "PTRequest.h"

typedef void (^PTMemoryPlayTurnRequestSuccessBlock) (NSDictionary* result);
typedef void (^PTMemoryPlayTurnRequestFailureBlock) (NSURLRequest* request, NSHTTPURLResponse* response, NSError* error, id JSON);

@interface PTMemoryPlayTurnRequest : PTRequest

- (void)placePieceAuthToken:(NSString *)token
                    user_id:(NSInteger)user_id
                   board_id:(NSInteger)board_id
                playdate_id:(NSInteger)playdate_id
                card1_index:(NSNumber *)card1_index
                card2_index:(NSNumber *)card2_index
                  onSuccess:(PTMemoryPlayTurnRequestSuccessBlock)success
                  onFailure:(PTMemoryPlayTurnRequestFailureBlock)failure;

@end
