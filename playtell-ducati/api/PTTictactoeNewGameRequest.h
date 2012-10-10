//
//  PTTictactoeNewGameRequest.h
//  playtell-ducati
//
//  Created by Giancarlo Daniele on 7/31/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import "PTRequest.h"

typedef void (^PTTictactoeNewGameRequestSuccessBlock) (NSDictionary* result);
typedef void (^PTTictactoeNewGameRequestFailureBlock) (NSURLRequest* request, NSHTTPURLResponse* response, NSError* error, id JSON);

@interface PTTictactoeNewGameRequest : PTRequest

- (void)newBoardWithPlaydateId:(NSNumber*)playdateId
                               authToken:(NSString*)token
                               playmate_id:(NSString *)playdateId
                               initiatorId:(NSString *)initiator_id
                               onSuccess:(PTTictactoeNewGameRequestSuccessBlock)success
                               onFailure:(PTTictactoeNewGameRequestFailureBlock)failure;

@end