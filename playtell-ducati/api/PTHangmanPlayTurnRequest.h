//
//  PTHangmanPlayTurnRequest.h
//  playtell-ducati
//
//  Created by Dimitry Bentsionov on 12/13/12.
//  Copyright (c) 2012 PlayTell. All rights reserved.
//

#import "PTRequest.h"

typedef void (^PTHangmanPlayTurnRequestSuccessBlock) (NSDictionary* result);
typedef void (^PTHangmanPlayTurnRequestFailureBlock) (NSURLRequest* request, NSHTTPURLResponse* response, NSError* error, id JSON);

@interface PTHangmanPlayTurnRequest : PTRequest

- (void)pickWordForBoardId:(NSInteger)boardId
                      word:(NSString *)word
                 authToken:(NSString *)token
                 onSuccess:(PTHangmanPlayTurnRequestSuccessBlock)success
                 onFailure:(PTHangmanPlayTurnRequestFailureBlock)failure;

- (void)guessLetterForBoardId:(NSInteger)boardId
                       letter:(NSString *)letter
                    authToken:(NSString *)token
                    onSuccess:(PTHangmanPlayTurnRequestSuccessBlock)success
                    onFailure:(PTHangmanPlayTurnRequestFailureBlock)failure;

- (void)drawShapeOnBoardId:(NSInteger)boardId
                 authToken:(NSString *)token
                 onSuccess:(PTHangmanPlayTurnRequestSuccessBlock)success
                 onFailure:(PTHangmanPlayTurnRequestFailureBlock)failure;

- (void)hangTheHangmanOnBoardId:(NSInteger)boardId
                      authToken:(NSString *)token
                      onSuccess:(PTHangmanPlayTurnRequestSuccessBlock)success
                      onFailure:(PTHangmanPlayTurnRequestFailureBlock)failure;

@end
