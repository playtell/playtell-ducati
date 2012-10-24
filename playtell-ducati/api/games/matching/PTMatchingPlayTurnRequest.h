//
//  PTMatchingPlayTurnRequest.h
//  playtell-ducati
//
//  Created by Dimitry Bentsionov on 10/23/12.
//  Copyright (c) 2012 PlayTell. All rights reserved.
//

#import "PTRequest.h"

typedef void (^PTMemoryPlayTurnRequestSuccessBlock) (NSDictionary* result);
typedef void (^PTMemoryPlayTurnRequestFailureBlock) (NSURLRequest* request, NSHTTPURLResponse* response, NSError* error, id JSON);

@interface PTMatchingPlayTurnRequest : PTRequest

- (void)playTurnWithBoardId:(NSInteger)boardId
                 card1Index:(NSInteger)card1Index
                 card2Index:(NSInteger)card2Index
                  authToken:(NSString *)token
                  onSuccess:(PTMemoryPlayTurnRequestSuccessBlock)success
                  onFailure:(PTMemoryPlayTurnRequestFailureBlock)failure;

@end