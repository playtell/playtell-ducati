//
//  PTHangmanNewGameRequest.h
//  playtell-ducati
//
//  Created by Dimitry Bentsionov on 12/13/12.
//  Copyright (c) 2012 PlayTell. All rights reserved.
//

#import "PTRequest.h"

typedef void (^PTHangmanNewGameRequestSuccessBlock) (NSDictionary* result);
typedef void (^PTHangmanNewGameRequestFailureBlock) (NSURLRequest* request, NSHTTPURLResponse* response, NSError* error, id JSON);

@interface PTHangmanNewGameRequest : PTRequest

- (void)newBoardWithPlaydateId:(NSInteger)playdateId
                    playmateId:(NSInteger)playmateId
                     authToken:(NSString*)token
                     onSuccess:(PTHangmanNewGameRequestSuccessBlock)success
                     onFailure:(PTHangmanNewGameRequestFailureBlock)failure;

@end