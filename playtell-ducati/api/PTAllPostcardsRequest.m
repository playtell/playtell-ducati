//
//  PTAllPostcardsRequest.m
//  playtell-ducati
//
//  Created by Adam Horne on 11/27/12.
//  Copyright (c) 2012 PlayTell. All rights reserved.
//

#import "AFNetworking.h"
#import "Logging.h"
#import "PTAllPostcardsRequest.h"

#import "NSMutableURLRequest+POSTParameters.h"

@implementation PTAllPostcardsRequest

- (void)allPostcardsWithUserID:(NSUInteger)userID
                       success:(PTAllPostcardsRequestSuccessBlock)success
                       failure:(PTAllPostcardsRequestFailureBlock)failure {
    LOGMETHOD;
    
    NSString* allPostcardsEndpoint = [NSString stringWithFormat:@"%@/api/postcard/all_photos.json", ROOT_URL];
    NSURL* allPostcardsURL = [NSURL URLWithString:allPostcardsEndpoint];
    
    NSDictionary* parameters = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithUnsignedInt:userID], @"user_id", nil];
    
    NSMutableURLRequest* allPostcardsRequest = [NSMutableURLRequest postRequestWithURL:allPostcardsURL];
    [allPostcardsRequest setPostParameters:parameters];
    
    AFJSONRequestOperation* operation;
    operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:allPostcardsRequest
                                                                success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
                 {
                     LogTrace(@"%@ response: %@", NSStringFromSelector(_cmd), JSON);
                     if (success) {
                         success(JSON);
                     }
                 } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                     LogError(@"%@ error :%@", NSStringFromSelector(_cmd), error);
                     if (failure) {
                         failure(request, response, error, JSON);
                     }
                 }];
    [operation start];
}

@end
