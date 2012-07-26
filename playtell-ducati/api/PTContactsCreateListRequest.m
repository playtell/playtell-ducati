//
//  PTContactsCreateListRequest.m
//  playtell-ducati
//
//  Created by Dimitry Bentsionov on 7/17/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import "PTContactsCreateListRequest.h"
#import "AFNetworking.h"
#import "NSMutableURLRequest+POSTParameters.h"
#import "NSString+UrlEncode.h"

@implementation PTContactsCreateListRequest

- (void)createList:(NSMutableArray *)contacts
         authToken:(NSString*)token
           success:(PTContactsCreateListRequestSuccessBlock)success
           failure:(PTContactsCreateListRequestFailureBlock)failure {
    
    NSError *jsonError;
    NSData *jsonContactsData = [NSJSONSerialization dataWithJSONObject:contacts options:0 error:&jsonError];
    NSString *jsonContacts = [[NSString alloc] initWithData:jsonContactsData encoding:NSUTF8StringEncoding];
    NSDictionary* postParameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [jsonContacts urlEncodedString], @"contacts",
                                    token, @"authentication_token",
                                    nil];
    
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/api/contacts/create_list", ROOT_URL]];
    NSMutableURLRequest* request = [NSMutableURLRequest postRequestWithURL:url];
    [request setPostParameters:postParameters];
    
    AFJSONRequestOperation* contactsCreateList;
    contactsCreateList = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
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
    [contactsCreateList start];
}

@end