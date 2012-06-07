//
//  PTPlaydate.m
//  playtell-ducati
//
//  Created by Ricky Hussmann on 6/2/12.
//  Copyright (c) 2012 PlayTell. All rights reserved.
//

#import "PTPlaydate.h"

@implementation PTPlaydate
@synthesize initiator;
@synthesize playmate;
@synthesize playdateID;
@synthesize pusherChannelName;
@synthesize initiatorTokboxToken;
@synthesize playmateTokboxToken;
@synthesize tokboxSessionID;

- (id)initWithPusherEvent:(PTPusherEvent*)channelEvent playmateFactory:(id<PTPlaymateFactory>)playmateFactory {

    if (self = [super init]) {
        NSAssert([channelEvent.data isKindOfClass:[NSDictionary class]], @"Expecting a dictionary of playdate data!");
        NSDictionary* playdateData = channelEvent.data;
        self.initiator = [playmateFactory playmateWithId:[[playdateData valueForKey:@"initiatorID"] unsignedIntValue]];
        self.playmate = [playmateFactory playmateWithId:[[playdateData valueForKey:@"playmateID"] unsignedIntValue]];
        self.playdateID = [[playdateData valueForKey:@"playdateID"] unsignedIntValue];
        self.pusherChannelName = [playdateData valueForKey:@"pusherChannelName"];
        self.initiatorTokboxToken = [playdateData valueForKey:@"tokboxInitiatorToken"];
        self.playmateTokboxToken = [playdateData valueForKey:@"tokboxPlaymateToken"];
        self.tokboxSessionID = [playdateData valueForKey:@"tokboxSessionID"];
    }
    return self;
}

- (NSString*)description {
    return [NSString stringWithFormat:@"Playdate ID: %u, Initiator: %@, Playmate: %@, Pusher channel name: %@,"
            @"Initiator token: %@, Playmate token: %@", self.playdateID, self.initiator, self.playmate, self.pusherChannelName,
            self.initiatorTokboxToken, self.playmateTokboxToken];
}

@end
