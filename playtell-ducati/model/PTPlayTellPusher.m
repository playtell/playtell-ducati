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
@property (nonatomic, retain) PTPusherPrivateChannel* playdateChannel;
@end

@implementation PTPlayTellPusher
static PTPlayTellPusher* instance = nil;
@synthesize pusherClient;
@synthesize rendezvousChannel, playdateChannel;
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

- (void)subscribeToPlaydateChannel:(NSString *)channelName {
    // Clean up channel name (ex: 'private-playdate-channel-944') that comes in via 'rendezvous-channel'
    // As per libPusher API - The "private-" prefix should be excluded from the name; it will be added automatically.
    // http://lukeredpath.github.com/libPusher/html/Classes/PTPusher.html#//api/name/subscribeToPrivateChannelNamed:
    channelName = [channelName stringByReplacingOccurrencesOfString:@"private-" withString:@""];
    self.playdateChannel = [self.pusherClient subscribeToPrivateChannelNamed:channelName];

    // Change book
    [self.playdateChannel bindToEventNamed:@"change_book" handleWithBlock:^(PTPusherEvent *channelEvent) {
        NSDictionary* eventData = channelEvent.data;
        NSLog(@"Playdate -> change_book: %@", eventData);
        [[NSNotificationCenter defaultCenter] postNotificationName:@"PlayDateChangeBook" object:self userInfo:eventData];
    }];
    
    // Close book
    [self.playdateChannel bindToEventNamed:@"close_book" handleWithBlock:^(PTPusherEvent *channelEvent) {
        NSDictionary* eventData = channelEvent.data;
        NSLog(@"Playdate -> close_book: %@", eventData);
        [[NSNotificationCenter defaultCenter] postNotificationName:@"PlayDateCloseBook" object:self userInfo:eventData];
    }];
    
    // Turn page
    [self.playdateChannel bindToEventNamed:@"turn_page" handleWithBlock:^(PTPusherEvent *channelEvent) {
        NSDictionary* eventData = channelEvent.data;
        NSLog(@"Playdate -> turn_page: %@", eventData);
        [[NSNotificationCenter defaultCenter] postNotificationName:@"PlayDateTurnPage" object:self userInfo:eventData];
    }];
    
    // End playdate
    [self.playdateChannel bindToEventNamed:@"end_playdate" handleWithBlock:^(PTPusherEvent *channelEvent) {
        NSDictionary* eventData = channelEvent.data;
        NSLog(@"Playdate -> end_playdate: %@", eventData);
        [[NSNotificationCenter defaultCenter] postNotificationName:@"PlayDateEndPlaydate" object:self userInfo:eventData];
        // Unsubscribe from this channel
        [self unsubscribeFromPlaydateChannel:channelEvent.channel];
    }];
}

- (void)unsubscribeFromPlaydateChannel:(NSString *)channelName {
    [self.pusherClient unsubscribeFromChannel:self.playdateChannel];
    self.playdateChannel = nil;
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
