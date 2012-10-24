//
//  PTMatchingNewGameRequest.h
//  playtell-ducati
//
//  Created by Dimitry Bentsionov on 10/23/12.
//  Copyright (c) 2012 PlayTell. All rights reserved.
//

#import "PTRequest.h"

typedef void (^PTMatchingNewGameRequestSuccessBlock) (NSDictionary* result);
typedef void (^PTMatchingNewGameRequestFailureBlock) (NSURLRequest* request, NSHTTPURLResponse* response, NSError* error, id JSON);

@interface PTMatchingNewGameRequest : PTRequest

- (void)newBoardWithInitiatorId:(NSInteger)initiatorId
                     playmateId:(NSInteger)playmateId
                     playdateId:(NSInteger)playdateId
                        themeId:(NSInteger)themeId
                       numCards:(NSInteger)numCards
                      authToken:(NSString*)token
                      onSuccess:(PTMatchingNewGameRequestSuccessBlock)success
                      onFailure:(PTMatchingNewGameRequestFailureBlock)failure;

@end