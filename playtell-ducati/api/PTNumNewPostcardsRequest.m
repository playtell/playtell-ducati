//
//  PTNumNewPostcardsRequest.m
//  playtell-ducati
//
//  Created by Adam Horne on 11/27/12.
//  Copyright (c) 2012 PlayTell. All rights reserved.
//

#import "AFNetworking.h"
#import "Logging.h"
#import "PTNumNewPostcardsRequest.h"

#import "NSMutableURLRequest+POSTParameters.h"

@implementation PTNumNewPostcardsRequest

- (void)numNewPostcardsWithUserID:(NSUInteger)userID
                          success:(PTNumNewPostcardsRequestSuccessBlock)success
                          failure:(PTNumNewPostcardsRequestFailureBlock)failure {
    LOGMETHOD;
    
    NSString* numNewPostcardsEndpoint = [NSString stringWithFormat:@"%@/api/postcard/num_new_photos.json", ROOT_URL];
    NSURL* numNewPostcardsURL = [NSURL URLWithString:numNewPostcardsEndpoint];
    
    NSDictionary* parameters = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithUnsignedInt:userID], @"user_id", nil];
    
    NSMutableURLRequest* numNewPostcardsRequest = [NSMutableURLRequest postRequestWithURL:numNewPostcardsURL];
    [numNewPostcardsRequest setPostParameters:parameters];
    
    AFJSONRequestOperation* operation;
    operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:numNewPostcardsRequest
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
