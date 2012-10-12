//
//  PTAnalytics.h
//  playtell-ducati
//
//  Created by Adam Horne on 10/11/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

// Names of events
#define EventBookRead                 @"Book read"
#define EventGamePlayed               @"Game played"
#define EventNUXEnded                 @"NUX ended"
#define EventNUXStarted               @"NUX started"
#define EventPlaydateCreated          @"Playdate created"
#define EventPlaydateEnded            @"Playdate ended"
#define EventPlaydateJoined           @"Playdate joined"
#define EventPlaymateJoinedMyPlaydate @"Playmate joined my playdate"
#define EventUsedFinger               @"Used finger"

// Names of properties passed in with events
#define PropBookId                    @"Book id"
#define PropDuration                  @"Duration"
#define PropGameName                  @"Game name"
#define PropPlaymateId                @"Playmate id"

#import <Foundation/Foundation.h>

@interface PTAnalytics : NSObject

+ (void)startAnalytics;
+ (void)setUniqueId:(NSString *)uniqueId;
+ (void)sendEventNamed:(NSString *)eventName;
+ (void)sendEventNamed:(NSString *)eventName withProperties:(NSDictionary *)properties;
+ (void)flush;

@end
