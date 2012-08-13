//
//  PTTictactoePlacePieceRequest.h
//  playtell-ducati
//
//  Created by Giancarlo Daniele on 7/31/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import "PTRequest.h"

typedef void (^PTTictactoePlacePieceRequestSuccessBlock) (NSDictionary* result);
typedef void (^PTTictactoePlacePieceRequestFailureBlock) (NSURLRequest* request, NSHTTPURLResponse* response, NSError* error, id JSON);

@interface PTTictactoePlacePieceRequest : PTRequest

- (void)placePieceWithCoordinates:(NSString *)coordinates
                        authToken:(NSString *)token
                          user_id:(NSString *)user_id
                         board_id:(NSString *)board_id
                      playdate_id:(NSString*)playdate_id
                        with_json:(NSString *)with_json
                        onSuccess:(PTTictactoePlacePieceRequestSuccessBlock)success
                        onFailure:(PTTictactoePlacePieceRequestFailureBlock)failure;

@end
