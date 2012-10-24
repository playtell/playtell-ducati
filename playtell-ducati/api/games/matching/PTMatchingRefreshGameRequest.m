//
//  PTMatchingRefreshGameRequest.m
//  playtell-ducati
//
//  Created by Dimitry Bentsionov on 10/23/12.
//  Copyright (c) 2012 PlayTell. All rights reserved.
//

#import "PTMatchingRefreshGameRequest.h"
#import "AFNetworking.h"
#import "NSMutableURLRequest+POSTParameters.h"

@implementation PTMatchingRefreshGameRequest

- (void)refreshBoardWithInitiatorId:(NSInteger)initiatorId
                         playmateId:(NSInteger)playmateId
                         playdateId:(NSInteger)playdateId
                            themeId:(NSInteger)themeId
                           numCards:(NSInteger)numCards
                          authToken:(NSString*)token
                          onSuccess:(PTMatchingRefreshGameRequestSuccessBlock)success
                          onFailure:(PTMatchingRefreshGameRequestFailureBlock)failure {
    
    NSDictionary* postParameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithInteger:initiatorId], @"initiator_id",
                                    [NSNumber numberWithInteger:playmateId], @"playmate_id",
                                    [NSNumber numberWithInteger:playdateId], @"playdate_id",
                                    [NSNumber numberWithInteger:themeId], @"theme_id",
                                    [NSNumber numberWithInteger:numCards], @"num_total_cards",
                                    @"true", @"already_playing",
                                    token, @"authentication_token",
                                    nil];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/api/games/matching/new_game", ROOT_URL]];
    NSMutableURLRequest* request = [NSMutableURLRequest postRequestWithURL:url];
    [request setPostParameters:postParameters];
    
    AFJSONRequestOperation* refreshGame;
    refreshGame = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
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
    [refreshGame start];
}

@end