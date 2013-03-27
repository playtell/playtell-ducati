//
//  PTHangmanEndGameRequest.m
//  playtell-ducati
//
//  Created by Dimitry Bentsionov on 12/13/12.
//  Copyright (c) 2012 PlayTell. All rights reserved.
//

#import "PTHangmanEndGameRequest.h"
#import "AFNetworking.h"
#import "NSMutableURLRequest+POSTParameters.h"

@implementation PTHangmanEndGameRequest

- (void)endGameWithBoardId:(NSInteger)boardId
                 authToken:(NSString*)token
                 onSuccess:(PTHangmanEndGameRequestSuccessBlock)success
                 onFailure:(PTHangmanEndGameRequestFailureBlock)failure {
    
    NSDictionary* postParameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithInteger:boardId], @"board_id",
                                    token, @"authentication_token",
                                    nil];
    
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/api/games/hangman/end_game", ROOT_URL]];
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