//
//  PTAnalytics.m
//  playtell-ducati
//
//  Created by Adam Horne on 10/11/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#ifdef PLAYTELL_STAGING
#define TOKEN @"7a22542c7451367f22a138d896707062"
#else
#define TOKEN @"d6aa6aa71c5114736094eea0645ed912"
#endif

#import "Mixpanel.h"
#import "PTAnalytics.h"

@implementation PTAnalytics

+ (void)startAnalytics {
    // Initialize Mixpanel with the right token
    Mixpanel *mixpanel = [Mixpanel sharedInstanceWithToken:TOKEN];
    
    // Set the time in between flushing events to the server
    mixpanel.flushInterval = 5;
}

+ (void)setUniqueId:(NSString *)uniqueId {
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    mixpanel.distinctId = uniqueId;
    mixpanel.nameTag = uniqueId;
}

+ (void)sendEventNamed:(NSString *)eventName {
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel track:eventName];
}

+ (void)sendEventNamed:(NSString *)eventName withProperties:(NSDictionary *)properties {
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel track:eventName properties:properties];
}

+ (void)flush {
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel flush];
}

@end
