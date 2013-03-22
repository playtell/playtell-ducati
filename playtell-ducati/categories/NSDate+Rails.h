//
//  NSDate+Rails.h
//  playtell-ducati
//
//  Created by Adam Horne on 2/21/13.
//  Copyright (c) 2013 PlayTell. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Rails)

+ (NSDate *)dateFromRailsString:(NSString *)railsString;

- (NSString *)railsString;

@end
