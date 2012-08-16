//
//  PTContactsNotify.m
//  playtell-ducati
//
//  Created by Dimitry Bentsionov on 8/9/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import "PTContactsNotifyRequest.h"
#import "AFNetworking.h"
#import "NSMutableURLRequest+POSTParameters.h"
#import "NSString+UrlEncode.h"

@implementation PTContactsNotifyRequest

- (void)notifyContacts:(NSArray *)contacts
               message:(NSString *)message
             authToken:(NSString *)token
               success:(PTContactsNotifyRequestSuccessBlock)success
               failure:(PTContactsNotifyRequestFailureBlock)failure {
    
    NSError *jsonError;
    NSData *jsonEmailsData = [NSJSONSerialization dataWithJSONObject:contacts options:0 error:&jsonError];
    NSString *jsonEmails = [[NSString alloc] initWithData:jsonEmailsData encoding:NSUTF8StringEncoding];

    NSDictionary* postParameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [jsonEmails urlEncodedString], @"emails",
                                    [message urlEncodedString], @"message",
                                    token, @"authentication_token",
                                    nil];
    
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/api/contacts/notify", ROOT_URL]];
    NSMutableURLRequest* request = [NSMutableURLRequest postRequestWithURL:url];
    [request setPostParameters:postParameters];
    
    AFJSONRequestOperation* contactsNotify;
    contactsNotify = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
                                                                         success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
                          {
                              if (success) {
                                  success(JSON);
                              }
                          } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                              if (failure) {
                                  failure(request, response, error, JSON);
                              }
                          }];
    [contactsNotify start];
}

@end