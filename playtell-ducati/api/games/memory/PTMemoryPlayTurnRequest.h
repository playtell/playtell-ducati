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

- (void)placePieceWithCoordinates:(NSString *)coordinates
                        authToken:(NSString *)token
                          user_id:(NSString *)user_id
                         board_id:(NSString *)board_id
                      playdate_id:(NSString *)playdate_id
                      card1_index:(NSString *)card1_index
                      card2_index:(NSString *)card2_index
                        onSuccess:(PTMemoryPlayTurnRequestSuccessBlock)success
                        onFailure:(PTMemoryPlayTurnRequestFailureBlock)failure;

@end
