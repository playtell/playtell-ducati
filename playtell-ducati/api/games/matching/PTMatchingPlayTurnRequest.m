//
//  PTMatchingPlayTurnRequest.m
//  playtell-ducati
//
//  Created by Dimitry Bentsionov on 10/23/12.
//  Copyright (c) 2012 PlayTell. All rights reserved.
//

#import "PTMatchingPlayTurnRequest.h"
#import "AFNetworking.h"
#import "NSMutableURLRequest+POSTParameters.h"

@implementation PTMatchingPlayTurnRequest

- (void)playTurnWithBoardId:(NSInteger)boardId
                 card1Index:(NSInteger)card1Index
                 card2Index:(NSInteger)card2Index
                  authToken:(NSString *)token
                  onSuccess:(PTMemoryPlayTurnRequestSuccessBlock)success
                  onFailure:(PTMemoryPlayTurnRequestFailureBlock)failure {
    
    NSDictionary* postParameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithInteger:boardId], @"board_id",
                                    [NSNumber numberWithInteger:card1Index], @"card1_index",
                                    [NSNumber numberWithInteger:card2Index], @"card2_index",
                                    token, @"authentication_token",
                                    nil];
    
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/api/games/matching/play_turn", ROOT_URL]];
    NSMutableURLRequest* request = [NSMutableURLRequest postRequestWithURL:url];
    [request setPostParameters:postParameters];
    
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

@end