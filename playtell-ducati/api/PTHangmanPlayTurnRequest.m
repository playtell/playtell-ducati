//
//  PTHangmanPlayTurnRequest.m
//  playtell-ducati
//
//  Created by Dimitry Bentsionov on 12/13/12.
//  Copyright (c) 2012 PlayTell. All rights reserved.
//

#import "PTHangmanPlayTurnRequest.h"
#import "AFNetworking.h"
#import "NSMutableURLRequest+POSTParameters.h"

@implementation PTHangmanPlayTurnRequest

- (void)playTurnUsingPostParameters:(NSDictionary*)postParameters
                          onSuccess:(PTHangmanPlayTurnRequestSuccessBlock)success
                          onFailure:(PTHangmanPlayTurnRequestFailureBlock)failure {
    
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/api/games/hangman/play_turn", ROOT_URL]];
    NSMutableURLRequest* request = [NSMutableURLRequest postRequestWithURL:url];
    [request setPostParameters:postParameters];
    NSLog(@"hangman/play_turn: %@", postParameters);
    
    AFJSONRequestOperation* playTurn;
    playTurn = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
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
    [playTurn start];
}

- (void)pickWordForBoardId:(NSInteger)boardId
                      word:(NSString *)word
                 authToken:(NSString *)token
                 onSuccess:(PTHangmanPlayTurnRequestSuccessBlock)success
                 onFailure:(PTHangmanPlayTurnRequestFailureBlock)failure {
    
    NSDictionary* postParameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithInteger:boardId], @"board_id",
                                    @"0", @"turn_type",
                                    word, @"word",
                                    token, @"authentication_token",
                                    nil];
    
    [self playTurnUsingPostParameters:postParameters onSuccess:success onFailure:failure];
}

- (void)guessLetterForBoardId:(NSInteger)boardId
                       letter:(NSString *)letter
                    authToken:(NSString *)token
                    onSuccess:(PTHangmanPlayTurnRequestSuccessBlock)success
                    onFailure:(PTHangmanPlayTurnRequestFailureBlock)failure {
    
    NSDictionary* postParameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithInteger:boardId], @"board_id",
                                    @"1", @"turn_type",
                                    letter, @"letter",
                                    token, @"authentication_token",
                                    nil];
    
    [self playTurnUsingPostParameters:postParameters onSuccess:success onFailure:failure];
}

- (void)drawShapeOnBoardId:(NSInteger)boardId
                 authToken:(NSString *)token
                 onSuccess:(PTHangmanPlayTurnRequestSuccessBlock)success
                 onFailure:(PTHangmanPlayTurnRequestFailureBlock)failure {
    
    NSDictionary* postParameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithInteger:boardId], @"board_id",
                                    @"2", @"turn_type",
                                    token, @"authentication_token",
                                    nil];
    
    [self playTurnUsingPostParameters:postParameters onSuccess:success onFailure:failure];    
}

- (void)hangTheHangmanOnBoardId:(NSInteger)boardId
                      authToken:(NSString *)token
                      onSuccess:(PTHangmanPlayTurnRequestSuccessBlock)success
                      onFailure:(PTHangmanPlayTurnRequestFailureBlock)failure {
    
    NSDictionary* postParameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithInteger:boardId], @"board_id",
                                    @"3", @"turn_type",
                                    token, @"authentication_token",
                                    nil];
    
    [self playTurnUsingPostParameters:postParameters onSuccess:success onFailure:failure];
}

@end
