//
//  NSDate+Rails.m
//  playtell-ducati
//
//  Created by Adam Horne on 2/21/13.
//  Copyright (c) 2013 PlayTell. All rights reserved.
//

#import "NSDate+Rails.h"

@implementation NSDate (Rails)

+ (NSDate *)dateFromRailsString:(NSString *)railsString {
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
    return [formatter dateFromString:railsString];
}

- (NSString *)railsString {
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
    return [formatter stringFromDate:self];
}

@end
