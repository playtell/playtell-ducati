//
//  PTChatViewController.m
//  playtell-ducati
//
//  Created by Ricky Hussmann on 8/14/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import "Logging.h"
#import "PTChatViewController.h"
#import "PTGetSampleOpenTokToken.h"
#import "PTNullPlaymate.h"
#import "PTUser.h"

#import "PTPlaydate+InitatorChecking.h"

@interface PTChatViewController ()
@property (nonatomic, strong) PTChatHUDView* chatView;
@property (nonatomic, strong) PTVideoPhone* videoPhone;
@end

@implementation PTChatViewController
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
//        [self setupPlaymatePlaceholderImages];
        [self setPlaymatePhoto];
        [self setCurrentUserPhoto];
    }
    return self;
}

- (id)initWithNullPlaymate {
    if (self = [super init]) {
        self.chatView = [[PTChatHUDView alloc] initWithFrame:CGRectZero];
        PTNullPlaymate* nullPlaymate = [[PTNullPlaymate alloc] init];
        [self.chatView setImageForRightView:nullPlaymate.userPhoto];
        [self connectToOpenTokSession];
    }
    return self;
}

- (void)reset {
    [self connectToOpenTokSession];
}

- (void)setLeftViewAsPlaceholder {
    [self.chatView setLeftView:[self playmatePlaceholderView]];
}

- (void)connectToOpenTokSession {
    NSString *myToken, *mySession;
    if ([[PTUser currentUser] isLoggedIn]) {
        [[PTVideoPhone sharedPhone] setSessionConnectedBlock:^(OTStream *subscriberStream, OTSession *session, BOOL isSelf) {
            LogDebug(@"Session connected");
        }];
        [[PTVideoPhone sharedPhone] setSubscriberConnectedBlock:^(OTSubscriber* subscriber) {
            LogDebug(@"Subscriber connected");
            [self.chatView setLeftView:subscriber.view];
        }];

        myToken = ([self.playdate isUserIDInitiator:[[PTUser currentUser] userID]]) ?
        self.playdate.initiatorTokboxToken : self.playdate.playmateTokboxToken;
        
        mySession = self.playdate.tokboxSessionID;
        
        // Begin duplicated code!
        [[PTVideoPhone sharedPhone] connectToSession:mySession
                                           withToken:myToken
                                             success:^(OTPublisher* publisher)
         {
             LogDebug(@"Connected to OpenTok session");
             [self.chatView setRightView:publisher.view];
         } failure:^(NSError* error) {
             LogError(@"Error connecting to OpenTok session: %@", error);
         }];
        //    [self setupPlaymatePlaceholderImages];
        [self setPlaymatePhoto];
        [self setCurrentUserPhoto];
        // End duplicated code!
    } else {
        PTGetSampleOpenTokToken* getTokBoxSession = [[PTGetSampleOpenTokToken alloc] init];
        [getTokBoxSession requestOpenTokSessionAndTokenWithSuccess:^(NSString *openTokSession, NSString *openTokToken)
        {
            // Begin duplicated code!
            [[PTVideoPhone sharedPhone] connectToSession:openTokSession
                                               withToken:openTokToken
                                                 success:^(OTPublisher* publisher)
             {
                 LogDebug(@"Connected to OpenTok session");
                 [self.chatView setRightView:publisher.view];
             } failure:^(NSError* error) {
                 LogError(@"Error connecting to OpenTok session: %@", error);
             }];
            //    [self setupPlaymatePlaceholderImages];
            [self setPlaymatePhoto];
            [self setCurrentUserPhoto];
            // End duplicated code!
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
            LogError(@"Error requesting TokBox token: %@", error);
        }];
    }
}

- (void)setupPlaymatePlaceholderImages {
    LOGMETHOD;
    [self.chatView setLoadingImageForLeftViewWithURL:self.playmate.photoURL
                                         loadingText:self.playmate.username];
    
    UIImageView* myImageView = [[UIImageView alloc] initWithImage:[[PTUser currentUser] userPhoto]];
    [self.chatView setRightView:myImageView];
}

- (void)setPlaymatePhoto {
    if (![[PTUser currentUser] isLoggedIn]) {
        [self.chatView setLeftView:[self playmatePlaceholderView]];
        return;
    }
    
    // Pick out the other user
    if (self.playdate) {
        PTPlaymate* otherUser;
        if ([self.playdate isUserIDInitiator:[[PTUser currentUser] userID]]) {
            otherUser = self.playdate.playmate;
        } else {
            otherUser = self.playdate.initiator;
        }
        
        UIImage* otherUserPhoto = (otherUser.userPhoto) ? otherUser.userPhoto : [self placeholderImage];
        [self.chatView setLoadingImageForLeftView:otherUserPhoto
                                      loadingText:otherUser.username];
    } else {
        [self.chatView setLoadingImageForLeftView:[self placeholderImage]
                                      loadingText:@""];
    }
}

- (UIView*)playmatePlaceholderView {
    CGRect dummyFrame = CGRectMake(0, 0, 200, 150);
    UIView *dummyBackground = [[UIView alloc] initWithFrame:dummyFrame];
    dummyBackground.backgroundColor = [UIColor colorWithRed:0.0f
                                                      green:0.0f
                                                       blue:0.0f
                                                      alpha:0.2f];
    dummyBackground.layer.cornerRadius = 10.0;
    dummyBackground.layer.borderColor = [UIColor whiteColor].CGColor;
    dummyBackground.layer.borderWidth = 6.0;
    
    CGSize maxTextSize = CGSizeMake(200.0, CGFLOAT_MAX);
    NSString* playmateText = NSLocalizedString(@"Playmate",
                                               @"Playmate placeholder string displayed in chat HUD.");
    UIFont* textFont = [UIFont fontWithName:@"HelveticaNeue-Bold"
                                       size:18.0f];
    CGSize textSize = [playmateText sizeWithFont:textFont
                               constrainedToSize:maxTextSize];
    CGRect textFrame = CGRectMake(roundf(CGRectGetMidX(dummyFrame)) - roundf(textSize.width/2.0),
                                  CGRectGetMaxY(dummyFrame) - 6.0 - textSize.height - 5.0,
                                  textSize.width,
                                  textSize.height);
    UILabel *textLabel = [[UILabel alloc] initWithFrame:textFrame];
    textLabel.backgroundColor = [UIColor clearColor];
    textLabel.font = textFont;
    textLabel.text = playmateText;
    [dummyBackground addSubview:textLabel];

    return dummyBackground;
}

- (void)setCurrentUserPhoto {
    UIImage* myPhoto = [[PTUser currentUser] userPhoto];
    
    // If user photo is nil user the placeholder
    myPhoto = (myPhoto) ? [[PTUser currentUser] userPhoto] : [self placeholderImage];
    [self.chatView setLoadingImageForRightView:myPhoto];
}

- (UIImage*)placeholderImage {
    return [UIImage imageNamed:@"profile_default_2.png"];
}

- (UIView*)view {
    return self.chatView;
}

@end
