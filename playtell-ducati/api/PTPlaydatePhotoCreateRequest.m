//
//  PTPlaydatePhotoCreateRequest.m
//  playtell-ducati
//
//  Created by Adam Horne on 10/26/12.
//  Copyright (c) 2012 PlayTell. All rights reserved.
//

#import "PTPlaydatePhotoCreateRequest.h"
#import "AFNetworking.h"

@implementation PTPlaydatePhotoCreateRequest

- (void)playdatePhotoCreateWithUserId:(NSInteger)userId
                           playdateId:(NSInteger)playdateId
                                photo:(UIImage *)photo
                              success:(PTPlaydatePhotoCreateRequestSuccessBlock)success
                              failure:(PTPlaydatePhotoCreateRequestFailureBlock)failure {
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd_HH-mm-ss"];
    NSString *dateString = [dateFormatter stringFromDate:[NSDate date]];
    
    NSString *filename = [NSString stringWithFormat:@"%d_%d_%@.png", userId, playdateId, dateString];
    
    NSDictionary* postParameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSString stringWithFormat:@"%d", userId], @"user_id",
                                    [NSString stringWithFormat:@"%d", playdateId], @"playdate_id",
                                    nil];
    
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:ROOT_URL]];
    NSData *imageData = UIImagePNGRepresentation(photo);
    NSURLRequest *request = [httpClient multipartFormRequestWithMethod:@"POST"
                                                                  path:@"/api/playdatephotos"
                                                            parameters:postParameters
                                             constructingBodyWithBlock: ^(id <AFMultipartFormData> formData) {
                                                 [formData appendPartWithFileData:imageData name:@"photo" fileName:filename mimeType:@"image/png"];
                                             }];
    
    AFJSONRequestOperation* createPlaydatePhoto;
    createPlaydatePhoto = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
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
    [createPlaydatePhoto start];
}

@end
