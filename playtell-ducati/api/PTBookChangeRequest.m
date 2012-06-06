//
//  PTBookChangeRequest.m
//  playtell-ducati
//
//  Created by Dimitry Bentsionov on 6/6/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import "PTBookChangeRequest.h"
#import "AFNetworking.h"
#import "NSMutableURLRequest+POSTParameters.h"

@implementation PTBookChangeRequest

- (void)changeBookWithPlaydateId:(NSNumber*)playdateId
                          bookId:(NSNumber*)bookId
                      pageNumber:(NSNumber*)pageNum
                       authToken:(NSString*)token
                       onSuccess:(PTBookChangeRequestSuccessBlock)success
                       onFailure:(PTBookChangeRequestFailureBlock)failure {
    
    NSDictionary* postParameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                    playdateId, @"playdate_id",
                                    bookId, @"book_id",
                                    pageNum, @"page_num",
                                    token, @"authentication_token",
                                    nil];
    
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/api/playdate/change_book.json", ROOT_URL]];
    NSMutableURLRequest* request = [NSMutableURLRequest postRequestWithURL:url];
    [request setPostParameters:postParameters];
    
    AFJSONRequestOperation* changeBook;
    changeBook = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
                                                               success:^(NSURLRequest *request,
                                                                         NSHTTPURLResponse *response,
                                                                         id JSON)
                {
                    success(JSON);
                } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                    failure(request, response, error, JSON);
                }];
    [changeBook start];
}

@end
