//
//  PTHangmanEndGameRequest.h
//  playtell-ducati
//
//  Created by Dimitry Bentsionov on 12/13/12.
//  Copyright (c) 2012 PlayTell. All rights reserved.
//

#import "PTRequest.h"

typedef void (^PTHangmanEndGameRequestSuccessBlock) (NSDictionary* result);
typedef void (^PTHangmanEndGameRequestFailureBlock) (NSURLRequest* request, NSHTTPURLResponse* response, NSError* error, id JSON);

@interface PTHangmanEndGameRequest : PTRequest

- (void)endGameWithBoardId:(NSInteger)boardId
                 authToken:(NSString*)token
                 onSuccess:(PTHangmanEndGameRequestSuccessBlock)success
                 onFailure:(PTHangmanEndGameRequestFailureBlock)failure;

@end