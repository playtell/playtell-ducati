//
//  PTContactsGetRelatedRequest.m
//  playtell-ducati
//
//  Created by Dimitry Bentsionov on 7/27/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import "PTContactsGetRelatedRequest.h"
#import "AFNetworking.h"
#import "NSMutableURLRequest+POSTParameters.h"

@implementation PTContactsGetRelatedRequest

- (void)getRelatedWithAuthToken:(NSString*)token
                        success:(PTContactsGetRelatedRequestSuccessBlock)success
                        failure:(PTContactsGetRelatedRequestFailureBlock)failure {
    
    NSDictionary* postParameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                    token, @"authentication_token",
                                    nil];
    
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/api/contacts/show_related", ROOT_URL]];
    NSMutableURLRequest* request = [NSMutableURLRequest postRequestWithURL:url];
    [request setPostParameters:postParameters];
    
    AFJSONRequestOperation* contactsGetRelated;
    contactsGetRelated = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
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
    [contactsGetRelated start];
}

@end