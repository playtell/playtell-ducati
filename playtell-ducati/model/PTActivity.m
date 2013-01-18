//
//  PTActivity.m
//  playtell-ducati
//
//  Created by Adam Horne on 1/18/13.
//  Copyright (c) 2013 PlayTell. All rights reserved.
//

#import "PTActivity.h"

@implementation PTActivity

@synthesize activityId;
@synthesize type;

- (id)init {
    self = [super init];
    if (self) {
        self.activityId = -1;
        self.type = ActivityUnknown;
    }
    return self;
}

- (NSString *)loggingString {
    NSString *activityType;
    switch (self.type) {
        case ActivityBook:
            activityType = @"ActivityBook";
            break;
        case ActivityGame:
            activityType = @"ActivityGame";
            break;
        default:
            activityType = @"ActivityUnknown";
            break;
    }
    return [NSString stringWithFormat:@"PTActivity data values: type => %@, activityId => %d", activityType, activityId];
}

@end
