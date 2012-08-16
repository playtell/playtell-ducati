//
//  PTChatViewController.m
//  playtell-ducati
//
//  Created by Ricky Hussmann on 8/14/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import "Logging.h"
#import "PTChatViewController.h"
#import "PTUser.h"

#import "PTPlaydate+InitatorChecking.h"

@interface PTChatViewController ()
@property (nonatomic, strong) PTChatHUDView* chatView;
@property (nonatomic, strong) PTVideoPhone* videoPhone;
@end

@implementation PTChatViewController
@synthesize view;
@synthesize chatView, videoPhone, playdate, playmate;

- (id)initWithplaydate:(PTPlaydate*)aPlaydate {
    if (self = [super init]) {
        self.chatView = [[PTChatHUDView alloc] initWithFrame:CGRectZero];
        self.playdate = aPlaydate;
        self.playmate = self.playdate.playmate;
        [self connectToOpenTokSession];
    }
    return self;
}

- (id)initWithPlaymate:(PTPlaymate*)aPlaymate {
    if (self = [super init]) {
        self.chatView = [[PTChatHUDView alloc] initWithFrame:CGRectZero];
        self.playmate = aPlaymate;
        [self setupPlaymatePlaceholderImages];
    }
    return self;
}

- (void)connectToOpenTokSession {
    [[PTVideoPhone sharedPhone] setSessionConnectedBlock:^(OTStream *subscriberStream, OTSession *session, BOOL isSelf) {
        LogDebug(@"Session connected");
    }];
    [[PTVideoPhone sharedPhone] setSubscriberConnectedBlock:^(OTSubscriber* subscriber) {
        LogDebug(@"Subscriber connected");
        [self.chatView setLeftView:subscriber.view];
    }];
    
    NSString* myToken = ([self.playdate isUserIDInitiator:[[PTUser currentUser] userID]]) ?
    self.playdate.initiatorTokboxToken : self.playdate.playmateTokboxToken;
    [[PTVideoPhone sharedPhone] connectToSession:self.playdate.tokboxSessionID
                                       withToken:myToken
                                         success:^(OTPublisher* publisher)
    {
        LogDebug(@"Connected to OpenTok session");
        [self.chatView setRightView:publisher.view];
    } failure:^(NSError* error) {
        LogError(@"Error connecting to OpenTok session: %@", error);
    }];
    [self setupPlaymatePlaceholderImages];
}

- (void)setupPlaymatePlaceholderImages {
    LOGMETHOD;
    [self.chatView setLoadingImageForLeftViewWithURL:self.playmate.photoURL
                                         loadingText:self.playmate.username];
    
    UIImageView* myImageView = [[UIImageView alloc] initWithImage:[[PTUser currentUser] userPhoto]];
    [self.chatView setRightView:myImageView];
}

@end
