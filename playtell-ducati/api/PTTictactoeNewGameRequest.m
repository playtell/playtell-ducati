//
//  PTTictactoeNewGameRequest.m
//  playtell-ducati
//
//  Created by Giancarlo Daniele on 7/31/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import "PTTictactoeNewGameRequest.h"
#import "AFNetworking.h"
#import "NSMutableURLRequest+POSTParameters.h"

@implementation PTTictactoeNewGameRequest

- (void)newBoardWithPlaydateId:(NSNumber*)playdateId
                        authToken:(NSString *)token
                        initiator_id:(NSNumber *)initiator_id
                        playmate_id:(NSString *)playmate_id
                        onSuccess:(PTTictactoeNewGameRequestSuccessBlock)success
                        onFailure:(PTTictactoeNewGameRequestFailureBlock)failure
{
    NSDictionary* postParameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                    playdateId, @"playdate_id",
                                    token, @"authentication_token",
                                    initiator_id, @"initiator_id",
                                    playmate_id, @"playmate_id",
                                    nil];

    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/api/games/tictactoe/new_game", ROOT_URL]];
    NSMutableURLRequest* request = [NSMutableURLRequest postRequestWithURL:url];
    [request setPostParameters:postParameters];
    
    AFJSONRequestOperation* newGame;
    newGame = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
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
    [newGame start];
}

@end
