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

- (void)newBoardWithPlaydateId:(NSInteger)playdateId
                    playmateId:(NSInteger)playmateId
                       themeId:(NSInteger)themeId
                      numCards:(NSInteger)numCards
                      gameName:(NSString*)gameName
                     authToken:(NSString*)token
                     onSuccess:(PTMatchingNewGameRequestSuccessBlock)success
                     onFailure:(PTMatchingNewGameRequestFailureBlock)failure;

@end