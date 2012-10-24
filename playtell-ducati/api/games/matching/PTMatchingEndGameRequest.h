//
//  PTMatchingEndGameRequest.h
//  playtell-ducati
//
//  Created by Giancarlo D on 9/5/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import "PTRequest.h"

typedef void (^PTMatchingEndGameRequestSuccessBlock) (NSDictionary* result);
typedef void (^PTMatchingEndGameRequestFailureBlock) (NSURLRequest* request, NSHTTPURLResponse* response, NSError* error, id JSON);

@interface PTMatchingEndGameRequest : PTRequest

- (void)endGameWithBoardId:(NSString *)boardId
                 authToken:(NSString*)token
                 onSuccess:(PTMatchingEndGameRequestSuccessBlock)success
                 onFailure:(PTMatchingEndGameRequestFailureBlock)failure;

@end