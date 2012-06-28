//
//  PTUsersGetStatusRequest.h
//  playtell-ducati
//
//  Created by Dimitry Bentsionov on 6/28/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import "PTRequest.h"

typedef void (^PTUsersGetStatusRequestSuccessBlock) (NSDictionary* result);
typedef void (^PTUsersGetStatusRequestFailureBlock) (NSURLRequest* request, NSHTTPURLResponse* response, NSError* error, id JSON);

@interface PTUsersGetStatusRequest : PTRequest

- (void)usersGetStatusForUserIds:(NSArray *)userIds
                       authToken:(NSString*)token
                         success:(PTUsersGetStatusRequestSuccessBlock)success
                         failure:(PTUsersGetStatusRequestFailureBlock)failure;

@end