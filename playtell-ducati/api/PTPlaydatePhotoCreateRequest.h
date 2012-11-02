//
//  PTPlaydatePhotoCreateRequest.h
//  playtell-ducati
//
//  Created by Adam Horne on 10/26/12.
//  Copyright (c) 2012 PlayTell. All rights reserved.
//

#import "PTRequest.h"

typedef void (^PTPlaydatePhotoCreateRequestSuccessBlock) (NSDictionary* result);
typedef void (^PTPlaydatePhotoCreateRequestFailureBlock) (NSURLRequest* request, NSHTTPURLResponse* response, NSError* error, id JSON);

@interface PTPlaydatePhotoCreateRequest : PTRequest

- (void)playdatePhotoCreateWithUserId:(NSInteger)userId
                           playdateId:(NSInteger)playdateId
                                photo:(UIImage *)photo
                              success:(PTPlaydatePhotoCreateRequestSuccessBlock)success
                              failure:(PTPlaydatePhotoCreateRequestFailureBlock)failure;

@end
