//
//  PTUserCreateRequest.m
//  playtell-ducati
//
//  Created by Dimitry Bentsionov on 9/14/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import "PTUserCreateRequest.h"
#import "AFNetworking.h"
#import "NSMutableURLRequest+POSTParameters.h"
#import "NSString+UrlEncode.h"

@implementation PTUserCreateRequest

- (void)userCreateWithName:(NSString *)name
                     email:(NSString *)email
                  password:(NSString *)password
                     photo:(UIImage *)photo
                 birthdate:(NSDate *)birthdate
                   success:(PTUserCreateRequestSuccessBlock)success
                   failure:(PTUserCreateRequestFailureBlock)failure {
    
    NSDictionary* postParameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                    name, @"name",
                                    email, @"email",
                                    password, @"password",
                                    nil];
    
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:ROOT_URL]];
    NSData *imageData = UIImagePNGRepresentation(photo);
    NSURLRequest *request = [httpClient multipartFormRequestWithMethod:@"POST"
                                                                  path:@"/api/users/create"
                                                            parameters:postParameters
                                             constructingBodyWithBlock: ^(id <AFMultipartFormData> formData) {
                                                 [formData appendPartWithFileData:imageData name:@"photo" fileName:@"photo.png" mimeType:@"image/png"];
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