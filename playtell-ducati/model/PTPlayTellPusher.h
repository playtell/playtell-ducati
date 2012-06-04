//
//  PTPlayTellPusher.h
//  playtell-ducati
//
//  Created by Ricky Hussmann on 6/2/12.
//  Copyright (c) 2012 PlayTell. All rights reserved.
//

#import "PTPlaydate.h"

#import <Foundation/Foundation.h>

@class PTPlayTellPusher;
@protocol PTPLayTellPusherDelegate <NSObject>
@required
- (void)playTellPusher:(PTPlayTellPusher*)pusher receivedPlaydateJoinedEvent:(PTPlaydate*)playdate;
- (void)playTellPusher:(PTPlayTellPusher*)pusher receivedPlaydateRequestedEvent:(PTPlaydate*)playdate;
@end

@interface PTPlayTellPusher : NSObject

+ (PTPlayTellPusher*)sharedPusher;

- (void)subscribeToRendezvousChannel;
- (void)unsubscribeFromRendezvousChannel;

@property (nonatomic, assign) id<PTPLayTellPusherDelegate> delegate;
@end
