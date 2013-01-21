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
@synthesize activityName;
@synthesize type;
@synthesize bookId;
@synthesize gameId;

- (id)init {
    self = [super init];
    if (self) {
        self.activityId = [NSNumber numberWithInt:-1];
        self.activityName = nil;
        self.type = ActivityUnknown;
        self.bookId = [NSNumber numberWithInt:-1];
        self.gameId = [NSNumber numberWithInt:-1];
    }
    return self;
}

- (id)initWithDictionary:(NSDictionary *)activity {
    self = [self init];
    if (self) {
        self.activityId = [activity objectForKey:@"id"];
        self.activityName = [activity objectForKey:@"title"];
        BOOL isBook = [[activity objectForKey:@"is_book"] boolValue];
        if (isBook) {
            self.type = ActivityBook;
            self.bookId = [NSNumber numberWithInt:[[activity objectForKey:@"book_id"] intValue]];
        } else {
            self.type = ActivityGame;
            self.gameId = [NSNumber numberWithInt:[[activity objectForKey:@"game_id"] intValue]];
        }
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
    return [NSString stringWithFormat:@"PTActivity data values: activityId => %d, name => %@, type => %@, bookId => %d, gameId => %d", [activityId intValue], activityName, activityType, [bookId intValue], [gameId intValue]];
}

@end
