//
//  PTActivity.h
//  playtell-ducati
//
//  Created by Adam Horne on 1/18/13.
//  Copyright (c) 2013 PlayTell. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    ActivityBook,
    ActivityGame,
    ActivityUnknown
} ActivityType;

@interface PTActivity : NSObject

@property (nonatomic, strong) NSNumber *activityId;
@property (nonatomic, strong) NSString *activityName;
@property (nonatomic) ActivityType type;
@property (nonatomic, strong) NSNumber *bookId;
@property (nonatomic, strong) NSNumber *gameId;

- (id)initWithDictionary:(NSDictionary *)activity;
- (NSString *)loggingString;

@end
