//
//  PTTictactoePlacePieceRequest.h
//  playtell-ducati
//
//  Created by Giancarlo Daniele on 7/31/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import "PTRequest.h"

typedef void (^PTTictactoePlacePieceRequestSuccessBlock) (NSDictionary* result);
typedef void (^PTTictactoePlacePieceRequestFailureBlock) (NSURLRequest* request, NSHTTPURLResponse* response, NSError* error, id JSON);

@interface PTTictactoePlacePieceRequest : PTRequest

@end
