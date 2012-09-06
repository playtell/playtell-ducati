//
//  PTMemoryPlayTurnRequest.m
//  playtell-ducati
//
//  Created by Giancarlo D on 9/5/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import "PTMemoryPlayTurnRequest.h"
#import "AFNetworking.h"
#import "NSMutableURLRequest+POSTParameters.h"

@implementation PTMemoryPlayTurnRequest

- (void)placePieceWithCoordinates:(NSString *)coordinates
                        authToken:(NSString *)token
                          user_id:(NSString *)user_id
                         board_id:(NSString *)board_id
                      playdate_id:(NSString *)playdate_id
                      card1_index:(NSString *)card1_index
                      card2_index:(NSString *)card2_index
                        onSuccess:(PTMemoryPlayTurnRequestSuccessBlock)success
                        onFailure:(PTMemoryPlayTurnRequestFailureBlock)failure
{
    NSDictionary* postParameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                    coordinates, @"coordinates",
                                    token, @"authentication_token",
                                    user_id, @"user_id",
                                    playdate_id, @"playdate_id",
                                    card1_index, @"card1_index",
                                    card2_index, @"card2_index",
                                    board_id, @"board_id",
                                    nil];
    
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/api/games/memory/play_turn", ROOT_URL]];
    NSMutableURLRequest* request = [NSMutableURLRequest postRequestWithURL:url];
    [request setPostParameters:postParameters];
    
    AFJSONRequestOperation* placePiece;
    placePiece = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
                                                                 success:^(NSURLRequest *request,
                                                                           NSHTTPURLResponse *response,
                                                                           id JSON)
                  {
                      if (success != nil) {
                          success(JSON); //network call is coming back from the server
                      }
                  } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                      if (failure != nil) {
                          failure(request, response, error, JSON); //some thing wrong
                      }
                  }];
    [placePiece start];
}

@end
