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

- (void)placePieceAuthToken:(NSString *)token
                    user_id:(NSInteger)user_id
                   board_id:(NSInteger)board_id
                playdate_id:(NSInteger)playdate_id
                card1_index:(NSNumber *)card1_index
                card2_index:(NSNumber *)card2_index
                  onSuccess:(PTMemoryPlayTurnRequestSuccessBlock)success
                  onFailure:(PTMemoryPlayTurnRequestFailureBlock)failure {

    NSDictionary* postParameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                    token, @"authentication_token",
                                    [NSNumber numberWithInteger:user_id], @"user_id",
                                    [NSNumber numberWithInteger:board_id], @"board_id",
                                    [NSNumber numberWithInteger:playdate_id], @"playdate_id",
                                    card1_index, @"card1_index",
                                    card2_index, @"card2_index",
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