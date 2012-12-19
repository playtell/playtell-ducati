//
//  PTHangmanNewGameRequest.m
//  playtell-ducati
//
//  Created by Dimitry Bentsionov on 12/13/12.
//  Copyright (c) 2012 PlayTell. All rights reserved.
//

#import "PTHangmanNewGameRequest.h"
#import "AFNetworking.h"
#import "NSMutableURLRequest+POSTParameters.h"

@implementation PTHangmanNewGameRequest

- (void)newBoardWithPlaydateId:(NSInteger)playdateId
                    playmateId:(NSInteger)playmateId
                     authToken:(NSString*)token
                     onSuccess:(PTHangmanNewGameRequestSuccessBlock)success
                     onFailure:(PTHangmanNewGameRequestFailureBlock)failure {
    
    NSDictionary* postParameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithInteger:playdateId], @"playdate_id",
                                    [NSNumber numberWithInteger:playmateId], @"playmate_id",
                                    token, @"authentication_token",
                                    nil];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/api/games/hangman/new_game", ROOT_URL]];
    NSMutableURLRequest* request = [NSMutableURLRequest postRequestWithURL:url];
    [request setPostParameters:postParameters];
    
    AFJSONRequestOperation* newGame;
    newGame = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
                                                              success:^(NSURLRequest *request,
                                                                        NSHTTPURLResponse *response,
                                                                        id JSON)
               {
                   if (success != nil) {
                       success(JSON);
                   }
               } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                   if (failure != nil) {
                       failure(request, response, error, JSON);
                   }
               }];
    [newGame start];
}

@end