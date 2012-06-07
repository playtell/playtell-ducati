//
//  PTVideoPhone.h
//  PlayTell
//
//  Created by Ricky Hussmann on 4/2/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Opentok/Opentok.h>

typedef void (^PTVideoConnectionSuccessBlock) (OTPublisher*);
typedef void (^PTVideoConnectionFailureBlock) (NSError*);
typedef void (^PTVideoSubscriberSubscribedBlock) (OTSubscriber*);
typedef void (^PTStreamConnectedToSessionBlock) (OTStream* subscriberStream, OTSession* session, BOOL isSelf);
typedef void (^PTSessionDroppedStreamBlock) (OTSession* session, OTStream* stream);

@interface PTVideoPhone : NSObject <OTSessionDelegate, OTSubscriberDelegate, OTPublisherDelegate>

- (void)connectToUser:(NSString*)aUser;
- (void)disconnect;

- (void)registerWithUserId:(NSString*)username;

- (void)connectToSession:(NSString*)aSession
               withToken:(NSString*)aToken
                 success:(PTVideoConnectionSuccessBlock)onSuccess
                 failure:(PTVideoConnectionFailureBlock)onFailure;

- (void)setSessionDropBlock:(PTSessionDroppedStreamBlock)handler;
- (void)setSessionConnectedBlock:(PTStreamConnectedToSessionBlock)handler;
- (void)setSubscriberConnectedBlock:(PTVideoSubscriberSubscribedBlock)handler;
@end
