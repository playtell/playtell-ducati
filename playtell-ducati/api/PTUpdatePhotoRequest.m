//
//  PTUpdatePhotoRequest.m
//  playtell-ducati
//
//  Created by Adam Horne on 2/20/13.
//  Copyright (c) 2013 PlayTell. All rights reserved.
//

#import "PTUpdatePhotoRequest.h"
#import "AFNetworking.h"
#import "NSMutableURLRequest+POSTParameters.h"
#import "NSString+UrlEncode.h"

@implementation PTUpdatePhotoRequest

- (void)updatePhotoWithUserId:(NSInteger)userId
                    authToken:(NSString*)token
                        photo:(UIImage *)photo
                      success:(PTUpdatePhotoRequestSuccessBlock)success
                      failure:(PTUpdatePhotoRequestFailureBlock)failure {
    
    NSDictionary* postParameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithInteger:userId], @"user_id",
                                    token, @"authentication_token",
                                    nil];
    
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:ROOT_URL]];
    NSData *imageData = UIImagePNGRepresentation(photo);
    NSURLRequest *request = [httpClient multipartFormRequestWithMethod:@"POST"
                                                                  path:@"/api/users/update.json"
                                                            parameters:postParameters
                                             constructingBodyWithBlock: ^(id <AFMultipartFormData> formData) {
                                                 [formData appendPartWithFileData:imageData name:@"user[photo]" fileName:@"photo.png" mimeType:@"image/png"];
                                             }];
    
    AFJSONRequestOperation* createUser;
    createUser = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
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
    [createUser start];
}

@end
