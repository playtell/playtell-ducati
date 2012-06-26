//
//  PTPlayTellPusher.h
//  playtell-ducati
//
//  Created by Ricky Hussmann on 6/2/12.
//  Copyright (c) 2012 PlayTell. All rights reserved.
//

#import "PTPlaydate.h"

#import <Foundation/Foundation.h>

extern NSString* const PTPlayTellPusherDidReceivePlaydateJoinedEvent;
extern NSString* const PTPlayTellPusherDidReceivePlaydateRequestedEvent;

extern NSString* const PTPlaydateKey;

@interface PTPlayTellPusher : NSObject

+ (PTPlayTellPusher*)sharedPusher;

- (void)subscribeToRendezvousChannel;
- (void)unsubscribeFromRendezvousChannel;
- (void)subscribeToPlaydateChannel:(NSString *)channelName;
- (void)unsubscribeFromPlaydateChannel:(NSString *)channelName;
- (void)emitEventNamed:(NSString *)name data:(id)data channel:(NSString *)channel;

@property (nonatomic, readonly) BOOL isSubscribedToPlaydateChannel;
@property (nonatomic) BOOL isSubscribedToRendezvousChannel;

@end
