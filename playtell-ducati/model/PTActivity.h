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

@property (nonatomic) int activityId;
@property (nonatomic) ActivityType type;

- (NSString *)loggingString;

@end
