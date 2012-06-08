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

@interface PTVideoPhone ()
@property (nonatomic, retain) OTSession *session;
@property (nonatomic, retain) OTPublisher *publisher;
@property (nonatomic, retain) OTSubscriber *subscriber;
@property (nonatomic, copy) PTVideoConnectionSuccessBlock successBlock;
@property (nonatomic, copy) PTVideoConnectionFailureBlock failureBlock;
@property (nonatomic, copy) PTStreamConnectedToSessionBlock connectedBlock;
@property (nonatomic, copy) PTVideoSubscriberSubscribedBlock subscribedBlock;
@property (nonatomic, copy) PTSessionDroppedStreamBlock sessionDroppedBlock;
@end

static NSString* const kApiKey = @"335312";
static PTVideoPhone* instance = nil;
@implementation PTVideoPhone
@synthesize session, publisher, subscriber;
@synthesize successBlock, failureBlock, connectedBlock, subscribedBlock, sessionDroppedBlock;

+ (PTVideoPhone*)sharedPhone {
    if (!instance) {
        instance = [[PTVideoPhone alloc] init];
    }
    return instance;
}

- (void)connectToSession:(NSString*)aSession
               withToken:(NSString*)aToken
                 success:(PTVideoConnectionSuccessBlock)onSuccess
                 failure:(PTVideoConnectionFailureBlock)onFailure {
    LOGMETHOD;
    LogTrace(@"%@ -> session ID: %@", NSStringFromSelector(_cmd), aSession);
    LogTrace(@"%@ -> token: %@", NSStringFromSelector(_cmd), aToken);
    
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

- (void)connectToUser:(NSString*)aUser {}
- (void)disconnect {
    LogInfo(@"OpenTok disconnecting");
    [self.session disconnect];
    self.session = nil;
    self.publisher = nil;
    self.subscriber = nil;
}

- (void)registerWithUserId:(NSString*)username {}

#pragma mark - OTSessionDelegate methods
- (void)sessionDidConnect:(OTSession*)aSession {
    LOGMETHOD;
    NSLog(@"Session connection id: %@", aSession.connection.connectionId);

    self.publisher = [[OTPublisher alloc] initWithDelegate:self];
    [self.session publish:self.publisher];

    if (self.successBlock) {
        self.successBlock(self.publisher);
    }
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
- (void)publisher:(OTPublisher*)publisher didFailWithError:(OTError*) error {}
- (void)publisherDidStartStreaming:(OTPublisher*)publisher {}
- (void)publisherDidStopStreaming:(OTPublisher*)publisher {}

@end
