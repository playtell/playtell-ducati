//
//  PTTictactoePlacePieceRequest.m
//  playtell-ducati
//
//  Created by Giancarlo Daniele on 7/31/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import "PTTictactoePlacePieceRequest.h"
#import "AFNetworking.h"
#import "NSMutableURLRequest+POSTParameters.h"

@implementation PTTictactoePlacePieceRequest

- (void)placePieceWithCoordinates:(NSNumber*)coordinates board_id:(NSString *)boardId user_id:(NSNumber *)userId                       authToken:(NSString*)token onSuccess:(PTTictactoePlacePieceRequestSuccessBlock)success onFailure:(PTTictactoePlacePieceRequestFailureBlock)failure
{
    NSDictionary* postParameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                    token, @"authentication_token",
                                    userId, @"user_id",
                                    boardId, @"board_id",
                                    coordinates, @"coordinates",
                                    nil];
    
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/api/games/tictactoe/place_piece", ROOT_URL]];
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
