//
//  PTVideoPhone.m
//  PlayTell
//
//  Created by Ricky Hussmann on 4/2/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import "Logging.h"
#import "PTUser.h"
#import "PTVideoPhone.h"
#import "TargetConditionals.h"

@interface PTVideoPhone ()
@property (nonatomic, retain) OTSession *session;
@property (nonatomic, retain) OTPublisher *publisher;
@property (nonatomic, retain) OTSubscriber *subscriber;
@property (nonatomic, copy) PTVideoConnectionSuccessBlock successBlock;
@property (nonatomic, copy) PTVideoConnectionFailureBlock failureBlock;
@property (nonatomic, copy) PTStreamConnectedToSessionBlock connectedBlock;
@property (nonatomic, copy) PTVideoSubscriberSubscribedBlock subscribedBlock;
@property (nonatomic, copy) PTSessionDroppedStreamBlock sessionDroppedBlock;
@property (nonatomic, copy) PTPublisherDidStartStreamingBlock publisherStreamingBlock;
@property (nonatomic, copy) PTPublisherDidStopStreamingBlock publisherStopStreamingBlock;

@property (nonatomic, copy) NSString* currentSessionToken;
@property (nonatomic, copy) NSString* currentUserToken;

@property (nonatomic, assign) UIBackgroundTaskIdentifier backgroundTask;
@end

static NSString* const kApiKey = @"335312";
static PTVideoPhone* instance = nil;
@implementation PTVideoPhone
@synthesize session, publisher, subscriber;
@synthesize successBlock, failureBlock, connectedBlock, subscribedBlock, sessionDroppedBlock, publisherStreamingBlock, publisherStopStreamingBlock;
@synthesize currentSessionToken, currentUserToken;
@synthesize backgroundTask;

+ (PTVideoPhone*)sharedPhone {
    if (!instance) {
        instance = [[PTVideoPhone alloc] init];
    }
    return instance;
}

- (id)init {
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(phoneDidBecomeActive:)
                                                     name:UIApplicationDidBecomeActiveNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(phoneDidEnterBackground:)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil];
    }
    return self;
}

- (UIView *)currentPublisherView {
    return self.publisher.view;
}

- (UIView *)currentSubscriberView {
    return self.subscriber.view;
}

- (void)phoneDidBecomeActive:(NSNotification *)note {
    LOGMETHOD;
    [self wakeUp];
}

- (void)phoneDidEnterBackground:(NSNotification *)note {
#if !(TARGET_IPHONE_SIMULATOR)
    backgroundTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler: ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (backgroundTask != UIBackgroundTaskInvalid)
            {
                [[UIApplication sharedApplication] endBackgroundTask:backgroundTask];
                backgroundTask = UIBackgroundTaskInvalid;
            }
        });
    }];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // Here goes your operation
        [self.session disconnect];
        self.session = nil;
        self.publisher = nil;
        self.subscriber = nil;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (backgroundTask != UIBackgroundTaskInvalid)
            {
                // if you don't call endBackgroundTask, the OS will exit your app.
                [[UIApplication sharedApplication] endBackgroundTask:backgroundTask];
                backgroundTask = UIBackgroundTaskInvalid;
            }
        });
    });
#endif
}

//associates ipad with session and communicates with server
- (void)connectToSession:(NSString*)aSession
               withToken:(NSString*)aToken
                 success:(PTVideoConnectionSuccessBlock)onSuccess
                 failure:(PTVideoConnectionFailureBlock)onFailure {
    LOGMETHOD;
    LogTrace(@"%@ -> session ID: %@", NSStringFromSelector(_cmd), aSession);
    LogTrace(@"%@ -> token: %@", NSStringFromSelector(_cmd), aToken);
    self.currentSessionToken = aSession;
    self.currentUserToken = aToken;
    
    self.session = [[OTSession alloc] initWithSessionId:aSession
                                               delegate:self];

    [self.session connectWithApiKey:kApiKey
                              token:aToken];

    self.successBlock = onSuccess;
    self.failureBlock = onFailure;
}

- (void)setSessionDropBlock:(PTSessionDroppedStreamBlock)handler {
    self.sessionDroppedBlock = handler;
}

- (void)setSessionConnectedBlock:(PTStreamConnectedToSessionBlock)handler {
    self.connectedBlock = handler;
}

- (void)setSubscriberConnectedBlock:(PTVideoSubscriberSubscribedBlock)handler {
    self.subscribedBlock = handler;
}

- (void)setPublisherDidStartStreamingBlock:(PTPublisherDidStartStreamingBlock)handler {
    self.publisherStreamingBlock = handler;
}

- (void)setPublisherDidStopStreamingBlock:(PTPublisherDidStopStreamingBlock)handler {
    self.publisherStopStreamingBlock = handler;
}

- (void)connectToUser:(NSString*)aUser {}
- (void)disconnect {
    LogInfo(@"OpenTok disconnecting");
    [self.session disconnect];
    self.session = nil;
    self.publisher = nil;
    self.subscriber = nil;
    self.currentUserToken = nil;
    self.currentSessionToken = nil;
}

- (void)wakeUp {
    LOGMETHOD;
    if (self.currentSessionToken && self.currentUserToken) {
        [self connectToSession:self.currentSessionToken
                     withToken:self.currentUserToken
                       success:self.successBlock
                       failure:self.failureBlock];
    }
}

- (void)registerWithUserId:(NSString*)username {}

#pragma mark - OTSessionDelegate methods
- (void)sessionDidConnect:(OTSession*)aSession {
    LOGMETHOD;
    NSLog(@"Session connection id: %@", aSession.connection.connectionId);
    
    // TODO this is a hack until I can figure out why this method gets
    // called twice after a wakeUp: call. The first time it is called
    // with a null connectionID. If the connectionID is null, then we
    // bail
    if (!aSession.connection.connectionId) {
        LogError(@"Connection ID is null");
        return;
    }

#if !(TARGET_IPHONE_SIMULATOR)
    self.publisher = [[OTPublisher alloc] initWithDelegate:self];
    self.publisher.delegate = self;
    [self.session publish:self.publisher];

    if (self.successBlock) {
        self.successBlock(self.publisher);
    }
#endif
}

- (void)sessionDidDisconnect:(OTSession*)session {
    LOGMETHOD;
}

- (void)session:(OTSession*)session didFailWithError:(OTError*)error {
    LOGMETHOD;
    if (self.failureBlock) {
        self.failureBlock(error);
    }
}

- (void)session:(OTSession*)aSession didReceiveStream:(OTStream*)aStream {
    LOGMETHOD;
    NSLog(@"Stream connection id: %@", aStream.connection.connectionId);
    NSLog(@"Local connection id: %@", aSession.connection.connectionId);

    // Don't subscribe to ourselves
    if ([aStream.connection.connectionId isEqualToString:aSession.connection.connectionId]) {
        if (self.connectedBlock) {
            self.connectedBlock(aStream, aSession, YES);
        }
        return;
    }

    self.subscriber = [[OTSubscriber alloc] initWithStream:aStream
                                                  delegate:self];

    if (self.connectedBlock) {
        self.connectedBlock(aStream, aSession, NO);
    }
}

- (void)session:(OTSession*)aSession didDropStream:(OTStream*)stream {
    LOGMETHOD;
    if (self.sessionDroppedBlock) {
        self.sessionDroppedBlock(aSession, stream);
    }
}


#pragma mark - OTSubscriberDelegate methods
- (void)subscriberDidConnectToStream:(OTSubscriber*)aSubscriber {
    LOGMETHOD;
    if (self.subscribedBlock) {
        self.subscribedBlock(aSubscriber);
    }
}
- (void)subscriber:(OTSubscriber*)subscriber didFailWithError:(OTError*)error {}
- (void)subscriberVideoDataReceived:(OTSubscriber*)subscriber {}

#pragma mark - OTPublisherDelegate methods
- (void)publisher:(OTPublisher*)publisher didFailWithError:(OTError*) error {
    LOGMETHOD;
    LogError(@"Error: %@", error);
}

- (void)publisherDidStartStreaming:(OTPublisher*)aPublisher {
    LOGMETHOD;
    if (self.publisherStreamingBlock) {
        self.publisherStreamingBlock(aPublisher);
    }
}

- (void)publisherDidStopStreaming:(OTPublisher*)aPublisher {
    LOGMETHOD;
    if (self.publisherStopStreamingBlock) {
        self.publisherStopStreamingBlock(aPublisher);
    }
}

@end
