//
//  PTUpdatePhotoRequest.h
//  playtell-ducati
//
//  Created by Adam Horne on 2/20/13.
//  Copyright (c) 2013 PlayTell. All rights reserved.
//

#import "PTRequest.h"

typedef void (^PTUpdatePhotoRequestSuccessBlock) (NSDictionary* result);
typedef void (^PTUpdatePhotoRequestFailureBlock) (NSURLRequest* request, NSHTTPURLResponse* response, NSError* error, id JSON);

@interface PTUpdatePhotoRequest : PTRequest

- (void)updatePhotoWithUserId:(NSInteger)userId
                    authToken:(NSString*)token
                        photo:(UIImage *)photo
                      success:(PTUpdatePhotoRequestSuccessBlock)success
                      failure:(PTUpdatePhotoRequestFailureBlock)failure;

@end
