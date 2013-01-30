//
//  PTContactsSearchRequest.m
//  playtell-ducati
//
//  Created by Adam Horne on 1/28/13.
//  Copyright (c) 2013 PlayTell. All rights reserved.
//

#import "PTContactsSearchRequest.h"
#import "AFNetworking.h"
#import "NSMutableURLRequest+POSTParameters.h"

@implementation PTContactsSearchRequest

- (void)searchWithAuthToken:(NSString *)token
               searchString:(NSString *)searchString
                    success:(PTContactsSearchRequestSuccessBlock)success
                    failure:(PTContactsSearchRequestFailureBlock)failure {
    NSDictionary* postParameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                    token, @"authentication_token", searchString, @"search_string",
                                    nil];
    
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/api/contacts/search.json", ROOT_URL]];
    NSMutableURLRequest* request = [NSMutableURLRequest postRequestWithURL:url];
    [request setPostParameters:postParameters];
    
    AFJSONRequestOperation* searchRequest;
    searchRequest = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
                                                                    success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
                     {
                         NSLog(@"JSON: %@", JSON);
                         if (success) {
                             NSArray *matches = [JSON objectForKey:@"matches"];
                             NSString *searchString = [JSON objectForKey:@"search_string"];
                             success(matches, searchString);
                         }
                     } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                         if (failure) {
                             failure(request, response, error, JSON);
                         }
                     }];
    [searchRequest start];
}

@end
