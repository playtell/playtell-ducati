//
//  PTContactsNotify.h
//  playtell-ducati
//
//  Created by Dimitry Bentsionov on 8/9/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import "PTRequest.h"

typedef void (^PTContactsNotifyRequestSuccessBlock) (NSDictionary* result);
typedef void (^PTContactsNotifyRequestFailureBlock) (NSURLRequest* request, NSHTTPURLResponse* response, NSError* error, id JSON);

@interface PTContactsNotifyRequest : PTRequest

- (void)notifyContacts:(NSArray *)contacts
               message:(NSString *)message
             authToken:(NSString *)token
               success:(PTContactsNotifyRequestSuccessBlock)success
               failure:(PTContactsNotifyRequestFailureBlock)failure;

@end