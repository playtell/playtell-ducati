//
//  PTPlaydate.h
//  playtell-ducati
//
//  Created by Ricky Hussmann on 6/2/12.
//  Copyright (c) 2012 PlayTell. All rights reserved.
//

#import "PTPlaymate.h"
#import "PTPlaymateFactory.h"
#import "PTPusherEvent.h"

#import <Foundation/Foundation.h>

@interface PTPlaydate : NSObject

- (id)initWithPusherEvent:(PTPusherEvent*)channelEvent playmateFactory:(id<PTPlaymateFactory>)playmateFactory;

@property (nonatomic, readwrite) PTPlaymate* initiator;
@property (nonatomic, readwrite) PTPlaymate* playmate;
@property (nonatomic, assign) NSUInteger playdateID;
@property (nonatomic, readwrite) NSString* pusherChannelName;
@property (nonatomic, readwrite) NSString* initiatorTokboxToken;
@property (nonatomic, readwrite) NSString* playmateTokboxToken;

@end
