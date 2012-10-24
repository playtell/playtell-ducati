//
//  PTMatchingRefreshGameRequest.h
//  playtell-ducati
//
//  Created by Dimitry Bentsionov on 10/23/12.
//  Copyright (c) 2012 PlayTell. All rights reserved.
//

#import "PTRequest.h"

typedef void (^PTMatchingRefreshGameRequestSuccessBlock) (NSDictionary* result);
typedef void (^PTMatchingRefreshGameRequestFailureBlock) (NSURLRequest* request, NSHTTPURLResponse* response, NSError* error, id JSON);

@interface PTMatchingRefreshGameRequest : PTRequest

- (void)refreshBoardWithInitiatorId:(NSInteger)initiatorId
                         playmateId:(NSInteger)playmateId
                         playdateId:(NSInteger)playdateId
                            themeId:(NSInteger)themeId
                           numCards:(NSInteger)numCards
                          authToken:(NSString*)token
                          onSuccess:(PTMatchingRefreshGameRequestSuccessBlock)success
                          onFailure:(PTMatchingRefreshGameRequestFailureBlock)failure;

@end