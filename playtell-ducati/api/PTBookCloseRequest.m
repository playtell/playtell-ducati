//
//  PTBookCloseRequest.m
//  playtell-ducati
//
//  Created by Dimitry Bentsionov on 6/6/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import "PTBookCloseRequest.h"
#import "AFNetworking.h"
#import "NSMutableURLRequest+POSTParameters.h"

@implementation PTBookCloseRequest

- (void)closeBookWithPlaydateId:(NSNumber*)playdateId
                         bookId:(NSNumber*)bookId
                      authToken:(NSString*)token
                      onSuccess:(PTBookCloseRequestSuccessBlock)success
                      onFailure:(PTBookCloseRequestFailureBlock)failure {
    
    NSDictionary* postParameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                    playdateId, @"playdate_id",
                                    bookId, @"book_id",
                                    token, @"authentication_token",
                                    nil];
    
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/api/playdate/close_book.json", ROOT_URL]];
    NSMutableURLRequest* request = [NSMutableURLRequest postRequestWithURL:url];
    [request setPostParameters:postParameters];
    
    AFJSONRequestOperation* closeBook;
    closeBook = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
                                                                 success:^(NSURLRequest *request,
                                                                           NSHTTPURLResponse *response,
                                                                           id JSON)
                  {
                      success(JSON);
                  } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                      failure(request, response, error, JSON);
                  }];
    [closeBook start];
}

@end
