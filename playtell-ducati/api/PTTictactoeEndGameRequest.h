//
//  PTTictactoeEndGameRequest.h
//  playtell-ducati
//
//  Created by Giancarlo Daniele on 8/21/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import "PTRequest.h"

typedef void (^PTTictactoeEndGameRequestSuccessBlock) (NSDictionary* result);
typedef void (^PTTictactoeEndGameRequestFailureBlock) (NSURLRequest* request, NSHTTPURLResponse* response, NSError* error, id JSON);

@interface PTTictactoeEndGameRequest : PTRequest

- (void)endGameWithBoardId:(NSString *)boardId
                     authToken:(NSString*)token
                     userId:(NSString*)userId
                     playdateId:(NSString*)playdateId
                     onSuccess:(PTTictactoeEndGameRequestSuccessBlock)success
                     onFailure:(PTTictactoeEndGameRequestFailureBlock)failure;

@end