//
//  PTChatViewController.m
//  playtell-ducati
//
//  Created by Ricky Hussmann on 8/14/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import "Logging.h"
#import "PTChatHUDView.h"
#import "PTChatHUDView2.h"
#import "PTChatViewController.h"
#import "PTGetSampleOpenTokToken.h"
#import "PTNullPlaymate.h"
#import "PTUser.h"

#import "PTPlaydate+InitatorChecking.h"
#import "UIView+PlayTell.h"

#import <MediaPlayer/MediaPlayer.h>

@interface PTChatViewController ()
@property (nonatomic, strong) PTChatHUDView2* chatView;
@property (nonatomic, strong) PTVideoPhone* videoPhone;
@property (nonatomic, strong) MPMoviePlayerController* movieController;
@end

@implementation PTChatViewController
@synthesize chatView, videoPhone, playdate, playmate;
@synthesize movieController;

- (void)playMovieURLInLeftPane:(NSURL*)movieURL {
    self.movieController.contentURL = movieURL;
    self.movieController.scalingMode = MPMovieScalingModeAspectFit;
    self.movieController.controlStyle = MPMovieControlStyleNone;
    [self.chatView setLeftView:self.movieController.view];
    [self.movieController play];
}

- (void)stopPlayingMovies {
    [self.movieController stop];
}

- (id)init {
    if (self = [super init]) {
        self.chatView = [[PTChatHUDView2 alloc] initWithFrame:CGRectZero];
        self.movieController = [[MPMoviePlayerController alloc] initWithContentURL:nil];
    }
    return self;
}

- (id)initWithplaydate:(PTPlaydate*)aPlaydate {
    if (self = [self init]) {
        self.playdate = aPlaydate;
        self.playmate = self.playdate.playmate;
        [self connectToOpenTokSession];
    }
    return self;
}

- (id)initWithPlaymate:(PTPlaymate*)aPlaymate {
    if (self = [self init]) {
        self.playmate = aPlaymate;
        [self setLoadingViewForPlaymate:aPlaymate];
        [self setCurrentUserPhoto];
    }
    return self;
}

- (id)initWithNullPlaymate {
    if (self = [self init]) {
        [self configureForDialpad];
    }
    return self;
}

- (void)configureForDialpad {
    PTNullPlaymate* nullPlaymate = [[PTNullPlaymate alloc] init];
    [self.chatView setImageForRightView:nullPlaymate.userPhoto];
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
        [[PTVideoPhone sharedPhone] setPublisherDidStartStreamingBlock:^(OTPublisher *aPublisher) {
            LogDebug(@"Publisher started streaming");
            [self.chatView setRightView:aPublisher.view];
        }];
        [[PTVideoPhone sharedPhone] connectToSession:mySession
                                           withToken:myToken
                                             success:NULL
                                             failure:^(NSError* error) {
             LogError(@"Error connecting to OpenTok session: %@", error);
         }];
        //    [self setupPlaymatePlaceholderImages];
        [self setCurrentUserPhoto];
        // End duplicated code!
    } else {
        [self connectToPlaceholderOpenTokSession];
    }
}

- (void)connectToPlaceholderOpenTokSession {
    PTGetSampleOpenTokToken* getTokBoxSession = [[PTGetSampleOpenTokToken alloc] init];
    [getTokBoxSession requestOpenTokSessionAndTokenWithSuccess:^(NSString *openTokSession, NSString *openTokToken)
     {
         [[PTVideoPhone sharedPhone] connectToSession:openTokSession
                                            withToken:openTokToken
                                              success:^(OTPublisher* publisher)
          {
              LogDebug(@"Connected to OpenTok session");
              [self.chatView setRightView:publisher.view];
          } failure:^(NSError* error) {
              LogError(@"Error connecting to OpenTok session: %@", error);
          }];
     } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
         LogError(@"Error requesting TokBox token: %@", error);
     }];
}

- (void)setupPlaymatePlaceholderImages {
    LOGMETHOD;
    [self.chatView setLoadingImageForLeftViewWithURL:self.playmate.photoURL
                                         loadingText:self.playmate.username];
    
    UIImageView* myImageView = [[UIImageView alloc] initWithImage:[[PTUser currentUser] userPhoto]];
    [self.chatView setRightView:myImageView];
}

- (void)setPlaymate:(PTPlaymate *)aPlaymate {
    UIImageView* anImageview = [[UIImageView alloc] initWithImage:playmate.userPhoto];
    anImageview.contentMode = UIViewContentModeScaleAspectFit;
    [self.chatView setLeftView:anImageview];
    playmate = aPlaymate;
}

- (void)setLoadingViewForPlaymate:(PTPlaymate*)aPlaymate {
    UIImageView *anImageView = [[UIImageView alloc] initWithImage:aPlaymate.userPhoto];
    anImageView.contentMode = UIViewContentModeScaleAspectFit;

    // Create the "ghosted" opacity view
    UIView *opacityView = [[UIView alloc] initWithFrame:anImageView.bounds];
    opacityView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    opacityView.backgroundColor = [UIColor colorWithRed:1.0f
                                                  green:1.0f
                                                   blue:1.0f
                                                  alpha:0.7f];
    [anImageView addSubview:opacityView];
    
    // Create and align the loading crank in the opacity view
    UIView *spinningCrank = [self createWaitingView];
    spinningCrank.center = opacityView.center;
    spinningCrank.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |
                                     UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    
    [opacityView addSubview:spinningCrank];
    
    // Determine the playmate name label geometry
    CGSize maxSize = CGSizeMake(200.0f, 50.0f);
    CGSize nameLabelSize = [aPlaymate.username sizeWithFont:[UIFont systemFontOfSize:18.0f]
                                          constrainedToSize:maxSize];

    CGPoint labelOrigin = CGPointMake((int)CGRectGetWidth(opacityView.frame)/2.0 - nameLabelSize.width/2.0,
                                      CGRectGetHeight(opacityView.frame) - nameLabelSize.height);
    CGRect nameLabelFrame = CGRectMake(labelOrigin.x,
                                       labelOrigin.y,
                                       nameLabelSize.width,
                                       nameLabelSize.height);

    // Create the name label and add it to the opacity view
    UILabel* nameLabel = [[UILabel alloc] initWithFrame:nameLabelFrame];
    nameLabel.text = aPlaymate.username;
    nameLabel.font = [UIFont systemFontOfSize:18.0f];
    nameLabel.backgroundColor = [UIColor clearColor];
    nameLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin |
                                 UIViewAutoresizingFlexibleRightMargin;
    [opacityView addSubview:nameLabel];
    
    [self.chatView setLeftView:anImageView];
    playmate = aPlaymate;
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

- (UIView*)createWaitingView {
    UIImage *loadingIcon = [UIImage imageNamed:@"logo_loading.gif"];
    UIImageView *iconImageview = [[UIImageView alloc] initWithImage:loadingIcon];
    iconImageview.frame = CGRectMake(0, 0, loadingIcon.size.width, loadingIcon.size.height);
    
    CATransform3D rotationsTransform = CATransform3DMakeRotation(1.0f * M_PI, 0, 0, 1.0);
    CABasicAnimation *rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
    
    rotationAnimation.toValue = [NSValue valueWithCATransform3D:rotationsTransform];
    rotationAnimation.duration = 2.0f;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = 10000;
    
    [iconImageview.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
    return iconImageview;
}

- (UIImage*)placeholderImage {
    return [UIImage imageNamed:@"profile_default_2.png"];
}

- (UIView*)view {
    return self.chatView;
}

@end
