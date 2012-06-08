//
//  PTPlayTellPusher.m
//  playtell-ducati
//
//  Created by Ricky Hussmann on 6/2/12.
//  Copyright (c) 2012 PlayTell. All rights reserved.
//

#import "Logging.h"
#import "PTPlayTellPusher.h"
#import "PTPusher.h"
#import "PTPusherChannel.h"
#import "PTPusherEvent.h"
#import "PTUser.h"

// TODO : Need to remove these dependencies after testing
#import "PTPlaydate.h"
#import "PTMockPlaymateFactory.h"

NSString* const PTPlayTellPusherDidReceivePlaydateJoinedEvent = @"PTPlayTellPusherDidReceivePlaydateJoinedEvent";
NSString* const PTPlayTellPusherDidReceivePlaydateRequestedEvent = @"PTPlayTellPusherDidReceivePlaydateRequestedEvent";

NSString* const PTPlaydateKey = @"PTPlaydateKey";

@interface PTPlayTellPusher () <PTPusherDelegate, PTPusherPresenceChannelDelegate>
@property (nonatomic, retain) PTPusher* pusherClient;
@property (nonatomic, retain) PTPusherPresenceChannel* rendezvousChannel;
@end

@implementation PTPlayTellPusher
static PTPlayTellPusher* instance = nil;
@synthesize pusherClient;
@synthesize rendezvousChannel;

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
        LogInfo(@"Playdate joined: %@", channelEvent);
        PTPlaydate* playdate = [[PTPlaydate alloc] initWithDictionary:channelEvent.data
                                                      playmateFactory:[[PTMockPlaymateFactory alloc] init]];

        NSDictionary* info = [NSDictionary dictionaryWithObject:playdate forKey:PTPlaydateKey];
        [[NSNotificationCenter defaultCenter] postNotificationName:PTPlayTellPusherDidReceivePlaydateJoinedEvent
                                                            object:self
                                                          userInfo:info];
    }];
    [self.rendezvousChannel bindToEventNamed:@"playdate_requested" handleWithBlock:^(PTPusherEvent *channelEvent) {
        LogInfo(@"Playdate requested: %@", channelEvent);
        PTPlaydate* playdate = [[PTPlaydate alloc] initWithDictionary:channelEvent.data
                                                      playmateFactory:[[PTMockPlaymateFactory alloc] init]];

        NSDictionary* info = [NSDictionary dictionaryWithObject:playdate forKey:PTPlaydateKey];
        [[NSNotificationCenter defaultCenter] postNotificationName:PTPlayTellPusherDidReceivePlaydateRequestedEvent
                                                            object:self
                                                          userInfo:info];
    }];
}

- (void)unsubscribeFromRendezvousChannel {
    if (self.rendezvousChannel) {
        [self.pusherClient unsubscribeFromChannel:self.rendezvousChannel];
    }
    self.rendezvousChannel = nil;
}

- (void)subscribeToPlaydateChannel:(NSString *)channelName {
    // Clean up channel name (ex: 'private-playdate-channel-944') that comes in via 'rendezvous-channel'
    // As per libPusher API - The "private-" prefix should be excluded from the name; it will be added automatically.
    // http://lukeredpath.github.com/libPusher/html/Classes/PTPusher.html#//api/name/subscribeToPrivateChannelNamed:
    channelName = [channelName stringByReplacingOccurrencesOfString:@"private-" withString:@""];
    PTPusherChannel* aPlaydateChannel = [self.pusherClient subscribeToPrivateChannelNamed:channelName];
    
    [aPlaydateChannel bindToEventNamed:@"pusher:subscription_succeeded" handleWithBlock:^(PTPusherEvent *channelEvent) {
        LogInfo(@"Playdate -> pusher:subscription_succeeded");
    }];

    // Change book
    [aPlaydateChannel bindToEventNamed:@"change_book" handleWithBlock:^(PTPusherEvent *channelEvent) {
        NSDictionary* eventData = channelEvent.data;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"PlayDateChangeBook" object:self userInfo:eventData];
    }];
    
    // Close book
    [aPlaydateChannel bindToEventNamed:@"close_book" handleWithBlock:^(PTPusherEvent *channelEvent) {
        NSDictionary* eventData = channelEvent.data;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"PlayDateCloseBook" object:self userInfo:eventData];
    }];
    
    // Turn page
    [aPlaydateChannel bindToEventNamed:@"turn_page" handleWithBlock:^(PTPusherEvent *channelEvent) {
        NSDictionary* eventData = channelEvent.data;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"PlayDateTurnPage" object:self userInfo:eventData];
    }];
    
    // End playdate
    [aPlaydateChannel bindToEventNamed:@"end_playdate" handleWithBlock:^(PTPusherEvent *channelEvent) {
        NSDictionary* eventData = channelEvent.data;
        LogInfo(@"Playdate -> end_playdate: %@", eventData);
        [[NSNotificationCenter defaultCenter] postNotificationName:@"PlayDateEndPlaydate" object:self userInfo:eventData];
    }];
}

- (void)unsubscribeFromPlaydateChannel:(NSString *)channelName {
    PTPusherChannel* channel = [self.pusherClient channelNamed:channelName];
    LogDebug(@"Attempting to unsubscribe from channel: %@", channelName);
    NSAssert(channel != nil, @"Trying to unsubscribe from a nil channel");
    [self.pusherClient unsubscribeFromChannel:channel];
}

#pragma mark PTPusherDelegate methods
- (void)pusher:(PTPusher *)pusher willAuthorizeChannelWithRequest:(NSMutableURLRequest *)request {
    NSString* headers = [[NSString alloc] initWithData:request.HTTPBody encoding:NSUTF8StringEncoding];
    NSString* appendedParameters = [headers stringByAppendingFormat:@"&authentication_token=%@", [[PTUser currentUser] authToken]];
    request.HTTPBody = [appendedParameters dataUsingEncoding:NSUTF8StringEncoding];
    LogTrace(@"Pusher auth request: %@", request.URL);
    LogTrace(@"Pusher auth parameters: %@", appendedParameters);
}

- (void)pusher:(PTPusher *)pusher didSubscribeToChannel:(PTPusherChannel *)channel {
    LOGMETHOD;
}

- (void)pusher:(PTPusher *)pusher didUnsubscribeFromChannel:(PTPusherChannel *)channel {
    LOGMETHOD;
}

- (void)pusher:(PTPusher *)pusher didFailToSubscribeToChannel:(PTPusherChannel *)channel withError:(NSError *)error {
    LOGMETHOD;
    LogError(@"%@", error);
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
