//
//  PTPlayTellPusher.m
//  playtell-ducati
//
//  Created by Ricky Hussmann on 6/2/12.
//  Copyright (c) 2012 PlayTell. All rights reserved.
//

#import "PTPlayTellPusher.h"
#import "PTPusher.h"
#import "PTPusherChannel.h"
#import "PTUser.h"

// TODO : Need to remove these dependencies after testing
#import "PTPlaydate.h"
#import "PTMockPlaymateFactory.h"

@interface PTPlayTellPusher () <PTPusherDelegate, PTPusherPresenceChannelDelegate>
@property (nonatomic, retain) PTPusher* pusherClient;
@property (nonatomic, retain) PTPusherPresenceChannel* rendezvousChannel;
@end

@implementation PTPlayTellPusher
static PTPlayTellPusher* instance = nil;
@synthesize pusherClient;
@synthesize rendezvousChannel;
@synthesize delegate;

+ (PTPlayTellPusher*)sharedPusher {
    if (instance == nil) {
        instance = [[PTPlayTellPusher alloc] init];
    }
    return instance;
}

- (id)init {
    if (self = [super init]) {
        self.pusherClient = [PTPusher pusherWithKey:@"cdac251f32d5b6d2ef7d" delegate:self encrypted:NO];
        self.pusherClient.authorizationURL = [self pusherAuthURL];
    }
    return self;
}

- (NSURL*)pusherAuthURL {
    NSString* urlString = [NSString stringWithFormat:@"%@/pusher/auth", ROOT_URL];
    return [NSURL URLWithString:urlString];
}

- (void)subscribeToRendezvousChannel {
    self.rendezvousChannel = [self.pusherClient subscribeToPresenceChannelNamed:@"rendezvous-channel" delegate:self];
    [self.rendezvousChannel bindToEventNamed:@"playdate_joined" handleWithBlock:^(PTPusherEvent *channelEvent) {
        NSLog(@"Playdate joined: %@", channelEvent);
        PTPlaydate* playdate = [[PTPlaydate alloc] initWithPusherEvent:channelEvent
                                                       playmateFactory:[[PTMockPlaymateFactory alloc] init]];
        [self.delegate playTellPusher:self receivedPlaydateJoinedEvent:playdate];
    }];
    [self.rendezvousChannel bindToEventNamed:@"playdate_requested" handleWithBlock:^(PTPusherEvent *channelEvent) {
        NSLog(@"Playdate requested: %@", channelEvent);
        PTPlaydate* playdate = [[PTPlaydate alloc] initWithPusherEvent:channelEvent
                                                       playmateFactory:[[PTMockPlaymateFactory alloc] init]];
        [self.delegate playTellPusher:self receivedPlaydateRequestedEvent:playdate];
    }];
}

- (void)unsubscribeFromRendezvousChannel {
    [self.pusherClient unsubscribeFromChannel:self.rendezvousChannel];
    self.rendezvousChannel = nil;
}

#pragma mark PTPusherDelegate methods
- (void)pusher:(PTPusher *)pusher willAuthorizeChannelWithRequest:(NSMutableURLRequest *)request {
    NSString* headers = [[NSString alloc] initWithData:request.HTTPBody encoding:NSUTF8StringEncoding];
    NSString* appendedParameters = [headers stringByAppendingFormat:@"&authentication_token=%@", [[PTUser currentUser] authToken]];
    request.HTTPBody = [appendedParameters dataUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"Pusher auth request: %@", request.URL);
    NSLog(@"Pusher auth parameters: %@", appendedParameters);
}

- (void)pusher:(PTPusher *)pusher didSubscribeToChannel:(PTPusherChannel *)channel {
    LOGMETHOD;
}

- (void)pusher:(PTPusher *)pusher didUnsubscribeFromChannel:(PTPusherChannel *)channel {
    LOGMETHOD;
}

- (void)pusher:(PTPusher *)pusher didFailToSubscribeToChannel:(PTPusherChannel *)channel withError:(NSError *)error {
    LOGMETHOD;
}

- (void)pusher:(PTPusher *)pusher didReceiveErrorEvent:(PTPusherErrorEvent *)errorEvent {
    LOGMETHOD;
}

#pragma mark PTPusherPresenceChannelDelegate methods
- (void)presenceChannel:(PTPusherPresenceChannel *)channel didSubscribeWithMemberList:(NSArray *)members {
    LOGMETHOD;
}

- (void)presenceChannel:(PTPusherPresenceChannel *)channel memberAddedWithID:(NSString *)memberID memberInfo:(NSDictionary *)memberInfo {
    LOGMETHOD;
}

- (void)presenceChannel:(PTPusherPresenceChannel *)channel memberRemovedWithID:(NSString *)memberID atIndex:(NSInteger)index {
    LOGMETHOD;
}

@end
