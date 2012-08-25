//
//  PTTictactoeRefreshGameRequest.m
//  playtell-ducati
//
//  Created by Giancarlo Daniele on 8/22/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import "PTTictactoeRefreshGameRequest.h"
#import "AFNetworking.h"
#import "NSMutableURLRequest+POSTParameters.h"

@implementation PTTictactoeRefreshGameRequest

- (void)refreshBoardWithPlaydateId:(NSNumber*)playdateId
                     authToken:(NSString *)token
                   playmate_id:(NSString *)playmate_id
                    already_playing:(NSNumber *)alreadyPlaying
                       initiatorId:(NSNumber *)initiatorId
                     onSuccess:(PTTictactoeRefreshGameRequestSuccessBlock)success
                     onFailure:(PTTictactoeRefreshGameRequestFailureBlock)failure
{
    NSDictionary* postParameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                    playdateId, @"playdate_id",
                                    token, @"authentication_token",
                                    playmate_id, @"playmate_id",
                                    alreadyPlaying, @"already_playing",
                                    initiatorId, @"initiator_id",
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
