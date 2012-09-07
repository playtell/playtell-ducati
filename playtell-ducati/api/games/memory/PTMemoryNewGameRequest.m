//
//  PTMemoryNewGameRequest.m
//  playtell-ducati
//
//  Created by Giancarlo D on 9/5/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import "PTMemoryNewGameRequest.h"
#import "AFNetworking.h"
#import "NSMutableURLRequest+POSTParameters.h"

@implementation PTMemoryNewGameRequest

- (void)newBoardWithPlaydate_id:(NSString *)playdate_id
                     auth_token:(NSString *)token
                    playmate_id:(NSString *)playmate_id
                    initiatorId:(NSString *)initiator_id
                       theme_ID:(NSString *)theme_id
                num_total_cards:(NSString *)num_total_cards
                      onSuccess:(PTMemoryNewGameRequestSuccessBlock)success
                      onFailure:(PTMemoryNewGameRequestFailureBlock)failure
{
    NSDictionary* postParameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                    playdate_id, @"playdate_id",
                                    token, @"authentication_token",
                                    initiator_id, @"initiator_id",
                                    playmate_id, @"playmate_id",
                                    theme_id, @"theme_id",
                                    num_total_cards, @"num_total_cards",
                                    nil];
    
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/api/games/memory/new_game", ROOT_URL]];
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
