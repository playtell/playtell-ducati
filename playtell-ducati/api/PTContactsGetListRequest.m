//
//  PTContactsGetListRequest.m
//  playtell-ducati
//
//  Created by Dimitry Bentsionov on 7/17/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import "PTContactsGetListRequest.h"
#import "AFNetworking.h"
#import "NSMutableURLRequest+POSTParameters.h"

@implementation PTContactsGetListRequest

- (void)getListWithAuthToken:(NSString*)token
                     success:(PTContactsGetListRequestSuccessBlock)success
                     failure:(PTContactsGetListRequestFailureBlock)failure {
    
    NSDictionary* postParameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                    token, @"authentication_token",
                                    nil];
    
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/api/contacts/show", ROOT_URL]];
    NSMutableURLRequest* request = [NSMutableURLRequest postRequestWithURL:url];
    [request setPostParameters:postParameters];
    
    AFJSONRequestOperation* contactsGetList;
    contactsGetList = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
                                                                         success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
                          {
                              if (success) {
                                  NSArray *contacts = [JSON objectForKey:@"contacts"];
                                  NSInteger total = [contacts count];
                                  success(contacts, total);
                              }
                          } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                              if (failure) {
                                  failure(request, response, error, JSON);
                              }
                          }];
    [contactsGetList start];
}

@end
