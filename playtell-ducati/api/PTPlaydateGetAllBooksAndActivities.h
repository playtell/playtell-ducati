//
//  PTPlaydateGetAllBooksAndActivities.h
//  playtell-ducati
//
//  Created by Giancarlo Daniele on 8/16/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import "PTRequest.h"

typedef void (^PTTictactoeNewGameRequestSuccessBlock) (NSDictionary* result);
typedef void (^PTTictactoeNewGameRequestFailureBlock) (NSURLRequest* request, NSHTTPURLResponse* response, NSError* error, id JSON);

@interface PTPlaydateGetAllBooksAndActivities : PTRequest

- (void)loadToybox; //for now this doesn't take in parameters

@end