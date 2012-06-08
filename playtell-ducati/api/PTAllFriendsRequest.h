//
//  PTAllFriendsRequest.h
//  playtell-ducati
//
//  Created by Ricky Hussmann on 6/8/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import "PTRequest.h"

@interface PTAllFriendsRequest : PTRequest

- (void)allFriendsWithUserID:(NSUInteger)userID
                   authToken:(NSString*)token;

@end
