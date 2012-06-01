//
//  NSDictionary+Util.m
//  PlayTell
//
//  Created by Ricky Hussmann on 3/23/12.
//  Copyright (c) 2012 PlayTell. All rights reserved.
//

#import "NSDictionary+Util.h"

@implementation NSDictionary (Util)

- (BOOL)containsKey:(NSString*)key {
    return ([self valueForKey:key] != nil);
}

@end
