//
//  PTMemoryEndGameRequest.h
//  playtell-ducati
//
//  Created by Giancarlo D on 9/5/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import "PTRequest.h"

typedef void (^PTMemoryEndGameRequestSuccessBlock) (NSDictionary* result);
typedef void (^PTMemoryEndGameRequestFailureBlock) (NSURLRequest* request, NSHTTPURLResponse* response, NSError* error, id JSON);

@interface PTMemoryEndGameRequest : PTRequest

- (void)endGameWithBoardId:(NSString *)boardId
                 authToken:(NSString*)token
                    userId:(NSString*)userId
                playdateId:(NSString*)playdateId
                 onSuccess:(PTMemoryEndGameRequestSuccessBlock)success
                 onFailure:(PTMemoryEndGameRequestFailureBlock)failure;

@end


