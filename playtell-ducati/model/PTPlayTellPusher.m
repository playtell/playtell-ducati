//
//  PTPlayTellPusher.m
//  playtell-ducati
//
//  Created by Ricky Hussmann on 6/2/12.
//  Copyright (c) 2012 PlayTell. All rights reserved.
//

#import "Logging.h"
#import "PTConcretePlaymateFactory.h"
#import "PTPlayTellPusher.h"
#import "PTPusher.h"
#import "PTPusherChannel.h"
#import "PTPusherEvent.h"
#import "PTUser.h"

// TODO : Need to remove these dependencies after testing
#import "PTPlaydate.h"

NSString* const PTPlayTellPusherDidReceivePlaydateJoinedEvent = @"PTPlayTellPusherDidReceivePlaydateJoinedEvent";
NSString* const PTPlayTellPusherDidReceivePlaydateRequestedEvent = @"PTPlayTellPusherDidReceivePlaydateRequestedEvent";
NSString* const PTPlayTellPusherDidReceivePlaydateEndedEvent = @"PTPlayTellPusherDidReceivePlaydateEndedEvent";

NSString* const PTPlaydateKey = @"PTPlaydateKey";

@interface PTPlayTellPusher () <PTPusherDelegate, PTPusherPresenceChannelDelegate>
@property (nonatomic, retain) PTPusher* pusherClient;
@property (nonatomic, retain) PTPusherPresenceChannel* rendezvousChannel;

@property (nonatomic, assign) BOOL shouldUnsubscribeFromRendezvous;
@end

@implementation PTPlayTellPusher
static PTPlayTellPusher* instance = nil;
@synthesize pusherClient;
@synthesize rendezvousChannel;
@synthesize isSubscribedToPlaydateChannel;
@synthesize isSubscribedToRendezvousChannel;
@synthesize shouldUnsubscribeFromRendezvous;

+ (PTPlayTellPusher*)sharedPusher {
    if (instance == nil) {
        instance = [[PTPlayTellPusher alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:instance
                                                 selector:@selector(disconnectPusherWhenEnteringBackground:)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil];
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
                                                      playmateFactory:[PTConcretePlaymateFactory sharedFactory]];

        NSDictionary* info = [NSDictionary dictionaryWithObject:playdate forKey:PTPlaydateKey];
        [[NSNotificationCenter defaultCenter] postNotificationName:PTPlayTellPusherDidReceivePlaydateJoinedEvent
                                                            object:self
                                                          userInfo:info];
    }];
    [self.rendezvousChannel bindToEventNamed:@"playdate_requested" handleWithBlock:^(PTPusherEvent *channelEvent) {
        LogInfo(@"Playdate requested: %@", channelEvent);
        PTPlaydate* playdate = [[PTPlaydate alloc] initWithDictionary:channelEvent.data
                                                      playmateFactory:[PTConcretePlaymateFactory sharedFactory]];

        NSDictionary* info = [NSDictionary dictionaryWithObject:playdate forKey:PTPlaydateKey];
        [[NSNotificationCenter defaultCenter] postNotificationName:PTPlayTellPusherDidReceivePlaydateRequestedEvent
                                                            object:self
                                                          userInfo:info];
    }];
    [self.rendezvousChannel bindToEventNamed:@"playdate_ended" handleWithBlock:^(PTPusherEvent *channelEvent) {
        LogInfo(@"Playdate ended: %@", channelEvent);
        PTPlaydate* playdate = [[PTPlaydate alloc] initWithDictionary:channelEvent.data
                                                      playmateFactory:[PTConcretePlaymateFactory sharedFactory]];
        
        NSDictionary* info = [NSDictionary dictionaryWithObject:playdate forKey:PTPlaydateKey];
        [[NSNotificationCenter defaultCenter] postNotificationName:PTPlayTellPusherDidReceivePlaydateEndedEvent
                                                            object:self
                                                          userInfo:info];
    }];
}

- (void)unsubscribeFromRendezvousChannel {

    // Trying to protect against a race condiction here where unsubscribe
    // is called on the rendezvous channel before the server acknowledges that
    // the channel is actually subscribed to (presenceChannel:didSubscribeWithMemberList:)
    //
    // If asked to unsubscribe from a channel that has not yet called the delegate method,
    // the shouldUnsubscribeFromRendezvousChannel flag is set, which the delegate method
    // presenceChannel:didSubscribeWithMemberList: will check when called, at which point
    // the delegate method will unsubscribe if the flag is set.
    
    if (self.isSubscribedToRendezvousChannel) {
        if (self.rendezvousChannel) {
            [self.pusherClient unsubscribeFromChannel:self.rendezvousChannel];
        }
        self.rendezvousChannel = nil;
        self.shouldUnsubscribeFromRendezvous = NO;
        self.isSubscribedToRendezvousChannel = NO;
    } else {
        self.shouldUnsubscribeFromRendezvous = YES;
        LogInfo(@"Asked to unsubscribe from a not-yet-fully-subscribed rendezvous channel");
    }
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
    
    // Finger tap
    [aPlaydateChannel bindToEventNamed:@"finger_tap" handleWithBlock:^(PTPusherEvent *channelEvent) {
        NSDictionary* eventData = channelEvent.data;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"PlayDateFingerStart" object:self userInfo:eventData];
    }];
    
    // Finger end
    [aPlaydateChannel bindToEventNamed:@"finger_end" handleWithBlock:^(PTPusherEvent *channelEvent) {
        NSDictionary* eventData = channelEvent.data;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"PlayDateFingerEnd" object:self userInfo:eventData];
    }];
    

    // ## GAMES START ##
    
    // tictactoe_new_game
    [aPlaydateChannel bindToEventNamed:@"games_tictactoe_new_game" handleWithBlock:^(PTPusherEvent *channelEvent) {
        NSDictionary* eventData = channelEvent.data;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"PlayDateTictactoeNewGame" object:self userInfo:eventData];
    }];
    
    // tictactoe_refresh_game
    [aPlaydateChannel bindToEventNamed:@"games_tictactoe_refresh_game" handleWithBlock:^(PTPusherEvent *channelEvent) {
        NSDictionary* eventData = channelEvent.data;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"PlayDateTictactoeRefreshGame" object:self userInfo:eventData];
    }];
    
    // tictactoe_end_game
    [aPlaydateChannel bindToEventNamed:@"games_tictactoe_end_game" handleWithBlock:^(PTPusherEvent *channelEvent) {
        NSDictionary* eventData = channelEvent.data;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"PlayDateTictactoeEndGame" object:self userInfo:eventData];
    }];
    
    // tictactoe_piece_placed
    [aPlaydateChannel bindToEventNamed:@"games_tictactoe_place_piece" handleWithBlock:^(PTPusherEvent *channelEvent) {
        NSDictionary* eventData = channelEvent.data;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"PlayDateTictactoePlacePiece" object:self userInfo:eventData];
    }];

    self.isSubscribedToPlaydateChannel = YES;
}

- (void)unsubscribeFromPlaydateChannel:(NSString *)channelName {
    PTPusherChannel* channel = [self.pusherClient channelNamed:channelName];
    LogDebug(@"Attempting to unsubscribe from channel: %@", channelName);
    if (!channel) {
        LogError(@"Attempting to unsubscribe from nil channel");
    } else {
        [self.pusherClient unsubscribeFromChannel:channel];
    }

    self.isSubscribedToPlaydateChannel = NO;
}

- (void)emitEventNamed:(NSString *)name data:(id)data channel:(NSString *)channel {
    [self.pusherClient sendEventNamed:name
                                 data:data
                              channel:channel
     ];
}

- (void)disconnectPusherWhenEnteringBackground:(NSNotification*)note {
    __block UIBackgroundTaskIdentifier taskID = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:taskID];
    }];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reconnectPusherWhenEnteringForeground:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    [self.pusherClient disconnect];
}

- (void)reconnectPusherWhenEnteringForeground:(NSNotificationCenter*)note {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationWillEnterForegroundNotification
                                                  object:nil];
    [self.pusherClient connect];
}

- (void)setIsSubscribedToPlaydateChannel:(BOOL)anIsSubscribedToPlaydateChannel {
    isSubscribedToPlaydateChannel = anIsSubscribedToPlaydateChannel;
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

- (void)pusher:(PTPusher *)pusher connectionDidConnect:(PTPusherConnection *)connection {
    LOGMETHOD;
}

- (void)pusher:(PTPusher *)pusher connectionDidDisconnect:(PTPusherConnection *)connection {
    LOGMETHOD;
}

- (void)pusher:(PTPusher *)pusher connection:(PTPusherConnection *)connection didDisconnectWithError:(NSError *)error {
    LOGMETHOD;
    if (error) {
        LogError(@"%@", error);
    }
}

- (void)pusher:(PTPusher *)pusher connection:(PTPusherConnection *)connection failedWithError:(NSError *)error {
    LOGMETHOD;
    LogError(@"%@", error);
}

#pragma mark PTPusherPresenceChannelDelegate methods
- (void)presenceChannel:(PTPusherPresenceChannel *)channel didSubscribeWithMemberList:(NSArray *)members {
    LOGMETHOD;

    // TODO : should check that this channel is the rendezvous channel, rather than
    // blindly assuming that it is
    self.isSubscribedToRendezvousChannel = YES;
    if (self.shouldUnsubscribeFromRendezvous) {
        [self unsubscribeFromRendezvousChannel];
        LogInfo(@"Now unsubscribing from a now-fully-subscribed rendezvous channel");
    }
}

- (void)presenceChannel:(PTPusherPresenceChannel *)channel memberAddedWithID:(NSString *)memberID memberInfo:(NSDictionary *)memberInfo {
    LOGMETHOD;
}

- (void)presenceChannel:(PTPusherPresenceChannel *)channel memberRemovedWithID:(NSString *)memberID atIndex:(NSInteger)index {
    LOGMETHOD;
}

@end
