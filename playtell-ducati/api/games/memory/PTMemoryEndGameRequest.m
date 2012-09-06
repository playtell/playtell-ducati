//
//  PTMemoryEndGameRequest.m
//  playtell-ducati
//
//  Created by Giancarlo D on 9/5/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import "PTMemoryEndGameRequest.h"
#import "AFNetworking.h"
#import "NSMutableURLRequest+POSTParameters.h"

@implementation PTMemoryEndGameRequest

- (void)endGameWithBoardId:(NSString *)boardId
                 authToken:(NSString *)token
                    userId:(NSString *)userId
                playdateId:(NSString*)playdateId
                 onSuccess:(PTMemoryEndGameRequestSuccessBlock)success
                 onFailure:(PTMemoryEndGameRequestFailureBlock)failure
{
    NSDictionary* postParameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                    boardId, @"board_id",
                                    token, @"authentication_token",
                                    userId, @"user_id",
                                    playdateId, @"playdate_id",
                                    nil];
    
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/api/games/memory/end_game", ROOT_URL]];
    NSMutableURLRequest* request = [NSMutableURLRequest postRequestWithURL:url];
    [request setPostParameters:postParameters];
    
    AFJSONRequestOperation* endGame;
    endGame = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
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
    [endGame start];
}

@end
