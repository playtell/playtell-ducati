//
//  NSMutableURLRequest+POSTParameters.m
//  playtell-ducati
//
//  Created by Ricky Hussmann on 5/31/12.
//  Copyright (c) 2012 PlayTell. All rights reserved.
//

#import "NSMutableURLRequest+POSTParameters.h"

@implementation NSMutableURLRequest (POSTParameters)

+ (NSMutableURLRequest*)postRequestWithURL:(NSURL*)url {
    NSMutableURLRequest* request = [self requestWithURL:url];
    request.HTTPMethod = @"POST";
    return request;
}

- (void)setPostParameters:(NSDictionary*)parameters {
    NSArray* keys = [parameters allKeys];
    NSString* parameterString = [NSString string];
    for (NSString* key in keys) {
        NSString* value = [parameters valueForKey:key];
        parameterString = [parameterString stringByAppendingFormat:@"%@=%@&", key, value];
    }

    // Trim off the last ampersand
    if (parameterString.length) {
        parameterString = [parameterString substringToIndex:parameterString.length - 1];
    }

    NSData* postData = [parameterString dataUsingEncoding:NSUTF8StringEncoding];
    self.HTTPBody = postData;
}

@end
