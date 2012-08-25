//
//  PTTictactoeRefreshGameRequest.h
//  playtell-ducati
//
//  Created by Giancarlo Daniele on 8/22/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import "PTRequest.h"

typedef void (^PTTictactoeRefreshGameRequestSuccessBlock) (NSDictionary* result);
typedef void (^PTTictactoeRefreshGameRequestFailureBlock) (NSURLRequest* request, NSHTTPURLResponse* response, NSError* error, id JSON);

@interface PTTictactoeRefreshGameRequest : PTRequest

- (void)refreshBoardWithPlaydateId:(NSNumber*)playdateId
                     authToken:(NSString*)token
                   playmate_id:(NSNumber*)playdateId
                   already_playing:(NSString*)alreadyPlaying
                       initiatorId:(NSNumber *)initiatorId
                     onSuccess:(PTTictactoeRefreshGameRequestSuccessBlock)success
                     onFailure:(PTTictactoeRefreshGameRequestFailureBlock)failure;

@end
