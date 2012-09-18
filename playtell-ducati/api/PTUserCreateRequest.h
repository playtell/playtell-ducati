//
//  PTUserCreateRequest.h
//  playtell-ducati
//
//  Created by Dimitry Bentsionov on 9/14/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import "PTRequest.h"

typedef void (^PTUserCreateRequestSuccessBlock) (NSDictionary* result);
typedef void (^PTUserCreateRequestFailureBlock) (NSURLRequest* request, NSHTTPURLResponse* response, NSError* error, id JSON);

@interface PTUserCreateRequest : PTRequest

- (void)userCreateWithName:(NSString *)name
                     email:(NSString *)email
                  password:(NSString *)password
                     photo:(UIImage *)photo
                 birthdate:(NSDate *)birthdate
         isAccountForChild:(BOOL)isAccountForChild
                   success:(PTUserCreateRequestSuccessBlock)success
                   failure:(PTUserCreateRequestFailureBlock)failure;

@end