//
//  PTAnalytics.h
//  playtell-ducati
//
//  Created by Adam Horne on 10/11/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

// Names of events
#define EventBookRead                  @"Book read"
#define EventGamePlayed                @"Game played"
#define EventNUXEnded                  @"NUX ended"
#define EventNUXStarted                @"NUX started"
#define EventPlaydateCreated           @"Playdate created"
#define EventPlaydateEnded             @"Playdate ended"
#define EventPlaydateJoined            @"Playdate joined"
#define EventPlaymateJoinedMyPlaydate  @"Playmate joined my playdate"
#define EventUsedFinger                @"Used finger"
#define EventNewUserStep1Info          @"New User: Step 1: Info"
#define EventNewUserStep2Photo         @"New User: Step 2: Photo"
#define EventNewUserStep3Birthday      @"New User: Step 3: Birthday"
#define EventNewUserStep4AccountCreate @"New User: Step 4: Account creation"
#define EventNewUserStep5Push          @"New User: Step 5: Push Notifications"
#define EventFriendInvitation          @"Friends invited"

// Names of properties passed in with events
#define PropUserId                    @"User id"
#define PropBookId                    @"Book id"
#define PropDuration                  @"Duration"
#define PropGameName                  @"Game name"
#define PropPlaymateId                @"Playmate id"
#define PropEmail                     @"Email"
#define PropPhotoSource               @"Profile photo source"
#define PropAccountCreation           @"Account creation successful"
#define PropPushSuccessful            @"Push notification successful"
#define PropNumContacts               @"Number invited"
#define PropContactSource             @"Contact source"

// Names of people properties
#define PeopleEmail                   @"$email"
#define PeopleUsername                @"$username"

#import <Foundation/Foundation.h>

@interface PTAnalytics : NSObject

+ (void)startAnalytics;
+ (void)setUniqueId:(NSString *)uniqueId;
+ (void)sendEventNamed:(NSString *)eventName;
+ (void)sendEventNamed:(NSString *)eventName withProperties:(NSDictionary *)properties;
+ (void)flush;

+ (void)setPeopleProperties:(NSDictionary *)properties;
+ (void)registerPushDeviceToken:(NSData *)token;

@end
