//
//  NSMutableURLRequest+POSTParameters.h
//  playtell-ducati
//
//  Created by Ricky Hussmann on 5/31/12.
//  Copyright (c) 2012 PlayTell. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableURLRequest (POSTParameters)

+ (NSMutableURLRequest*)postRequestWithURL:(NSURL*)url;

- (void)setPostParameters:(NSDictionary*)parameters;

@end
