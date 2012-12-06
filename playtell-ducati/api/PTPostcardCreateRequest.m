//
//  PTPostcardCreateRequest.m
//  playtell-ducati
//
//  Created by Adam Horne on 11/27/12.
//  Copyright (c) 2012 PlayTell. All rights reserved.
//

#import "PTPostcardCreateRequest.h"
#import "AFNetworking.h"

@implementation PTPostcardCreateRequest

- (void)postcardCreateWithUserId:(NSInteger)senderId
                      playmateId:(NSInteger)receiverId
                           photo:(UIImage *)photo
                         success:(PTPostcardCreateRequestSuccessBlock)success
                         failure:(PTPostcardCreateRequestFailureBlock)failure {
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd_HH-mm-ss"];
    NSString *dateString = [dateFormatter stringFromDate:[NSDate date]];
    
    NSString *filename = [NSString stringWithFormat:@"%d_%d_%@.png", senderId, receiverId, dateString];
    
    NSDictionary* postParameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSString stringWithFormat:@"%d", senderId], @"sender_id",
                                    [NSString stringWithFormat:@"%d", receiverId], @"receiver_id",
                                    nil];
    
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:ROOT_URL]];
    NSData *imageData = UIImagePNGRepresentation(photo);
    NSURLRequest *request = [httpClient multipartFormRequestWithMethod:@"POST"
                                                                  path:@"/api/postcards.json"
                                                            parameters:postParameters
                                             constructingBodyWithBlock: ^(id <AFMultipartFormData> formData) {
                                                 [formData appendPartWithFileData:imageData name:@"photo" fileName:filename mimeType:@"image/png"];
                                             }];
    
    AFJSONRequestOperation* createPostcard;
    createPostcard = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
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
    [createPostcard start];
}

@end
