//
//  PTBooksListRequest.m
//  playtell-ducati
//
//  Created by Dimitry Bentsionov on 6/5/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import "PTBooksListRequest.h"
#import "AFNetworking.h"
#import "NSMutableURLRequest+POSTParameters.h"

@implementation PTBooksListRequest

- (void)booksListWithAuthToken:(NSString*)token
                     onSuccess:(PTBooksListRequestSuccessBlock)success
                     onFailure:(PTBooksListRequestFailureBlock)failure {
    
    NSDictionary* postParameters = [NSDictionary dictionaryWithObjectsAndKeys:token, @"authentication_token", nil];
    
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/api/books/list.json", ROOT_URL]];
    NSMutableURLRequest* request = [NSMutableURLRequest postRequestWithURL:url];
    [request setPostParameters:postParameters];
    
    AFJSONRequestOperation* booksList;
    booksList = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
                                                                     success:^(NSURLRequest *request,
                                                                               NSHTTPURLResponse *response,
                                                                               id JSON)
                      {
                          if (success != nil) {
                              success(JSON);
                          }
                      } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                          if (failure != nil) {
                              failure(request, response, error, JSON);
                          }
                      }];
    [booksList start];
}

@end
