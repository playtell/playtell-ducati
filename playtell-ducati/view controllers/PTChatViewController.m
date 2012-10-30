//
//  PTChatViewController.m
//  playtell-ducati
//
//  Created by Ricky Hussmann on 8/14/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import "Logging.h"
#import "PTChatHUDView.h"
#import "PTChatViewController.h"
#import "PTGetSampleOpenTokToken.h"
#import "PTNullPlaymate.h"
#import "PTPlaydatePhotoCreateRequest.h"
#import "PTUser.h"

#import "PTPlaydate+InitatorChecking.h"
#import "UIView+PlayTell.h"
#import "UIColor+ColorFromHex.h"

#import <MediaPlayer/MediaPlayer.h>

#define CHATVIEW_CENTERX        512.0
#define CHATVIEW_LARGE_HEIGHT   300.0
#define CHATVIEW_LARGE_WIDTH    800.0
#define CHATVIEW_SMALL_HEIGHT   150.0
#define CHATVIEW_SMALL_WIDTH    400.0

@interface PTChatViewController ()
@property (nonatomic, strong) PTChatHUDView* chatView;
@property (nonatomic, strong) PTVideoPhone* videoPhone;
@property (nonatomic, strong) MPMoviePlayerController* movieController;
@property (nonatomic, assign) BOOL restrictSizeToSmall;
@end

@implementation PTChatViewController
@synthesize chatView, videoPhone, playdate, playmate;
@synthesize movieController;
@synthesize restrictSizeToSmall;

NSTimer *screenshotTimer;

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
        self.chatView = [[PTChatHUDView alloc] initWithFrame:CGRectMake(CHATVIEW_CENTERX - (CHATVIEW_SMALL_WIDTH / 2), 0.0f, CHATVIEW_SMALL_WIDTH, CHATVIEW_SMALL_HEIGHT)];
        self.movieController = [[MPMoviePlayerController alloc] initWithContentURL:nil];
        self.restrictSizeToSmall = YES;
        
        // Create the gesture recognizers
        UISwipeGestureRecognizer *swipeDownRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(userSwipeDownEvent:)];
        swipeDownRecognizer.direction = UISwipeGestureRecognizerDirectionDown;
        UISwipeGestureRecognizer *swipeUpRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(userSwipeUpEvent:)];
        swipeUpRecognizer.direction = UISwipeGestureRecognizerDirectionUp;
        UIPinchGestureRecognizer *pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(userPinchEvent:)];
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userTapEvent:)];
        tapRecognizer.numberOfTapsRequired = 1;
        
        
        // Add the gesture recognizers to the view
        [self.chatView addGestureRecognizer:swipeDownRecognizer];
        [self.chatView addGestureRecognizer:swipeUpRecognizer];
        [self.chatView addGestureRecognizer:pinchRecognizer];
        [self.chatView addGestureRecognizer:tapRecognizer];
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

- (void)takeScreenshotWithSave:(BOOL)saveToCameraRoll {
    dispatch_async(dispatch_get_current_queue(), ^{
        UIImage *screenshot = [self.chatView screenshotWithSave:saveToCameraRoll];
        
        PTPlaydatePhotoCreateRequest *photoCreateRequest = [[PTPlaydatePhotoCreateRequest alloc] init];
        [photoCreateRequest playdatePhotoCreateWithUserId:[PTUser currentUser].userID
                                               playdateId:self.playdate.playdateID
                                                    photo:screenshot
                                                  success:^(NSDictionary *result) {
                                                      //NSLog(@"Playdate photo successfully uploaded.");
                                                  } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                      NSLog(@"Playdate photo creation failure!! %@ - %@", error, JSON);
                                                  }];
    });
}

- (void)takeAutomaticScreenshot {
    [self takeScreenshotWithSave:NO];
}

- (void)startAutomaticPicturesWithInterval:(float)interval {
    screenshotTimer = [NSTimer scheduledTimerWithTimeInterval:interval
                                                       target:self
                                                     selector:@selector(takeAutomaticScreenshot) userInfo:nil
                                                      repeats:YES];
}

- (void)stopAutomaticPictures {
    [screenshotTimer invalidate];
}

- (void)restrictToSmallSize:(BOOL)shouldRestrict {
    if (shouldRestrict && self.chatView.frame.size.width != CHATVIEW_SMALL_WIDTH) {
        self.chatView.frame = CGRectMake(CHATVIEW_CENTERX - (CHATVIEW_SMALL_WIDTH / 2), 0.0f, CHATVIEW_SMALL_WIDTH, CHATVIEW_SMALL_HEIGHT);
    }
    
    self.restrictSizeToSmall = shouldRestrict;
}

- (void)userSwipeDownEvent:(UISwipeGestureRecognizer *)recognizer {
    if (self.restrictSizeToSmall)
        return;
    
    if (self.chatView.frame.size.width != CHATVIEW_LARGE_WIDTH) {
        self.chatView.frame = CGRectMake(CHATVIEW_CENTERX - (CHATVIEW_LARGE_WIDTH / 2), 0.0f, CHATVIEW_LARGE_WIDTH, CHATVIEW_LARGE_HEIGHT);
    }
}

- (void)userSwipeUpEvent:(UISwipeGestureRecognizer *)recognizer {
    if (self.restrictSizeToSmall)
        return;
    
    if (self.chatView.frame.size.width != CHATVIEW_SMALL_WIDTH) {
        self.chatView.frame = CGRectMake(CHATVIEW_CENTERX - (CHATVIEW_SMALL_WIDTH / 2), 0.0f, CHATVIEW_SMALL_WIDTH, CHATVIEW_SMALL_HEIGHT);
    }
}

- (void)userPinchEvent:(UIPinchGestureRecognizer *)recognizer {
    if (self.restrictSizeToSmall)
        return;
    
    if (recognizer.state == UIGestureRecognizerStateBegan ||
        recognizer.state == UIGestureRecognizerStateChanged) {
        CGFloat scale = recognizer.scale;
        
        float newWidth = self.chatView.frame.size.width * scale;
        if (newWidth < CHATVIEW_SMALL_WIDTH)
            newWidth = CHATVIEW_SMALL_WIDTH;
        if (newWidth > CHATVIEW_LARGE_WIDTH)
            newWidth = CHATVIEW_LARGE_WIDTH;
        
        float newHeight = self.chatView.frame.size.height * scale;
        if (newHeight < CHATVIEW_SMALL_HEIGHT)
            newHeight = CHATVIEW_SMALL_HEIGHT;
        if (newHeight > CHATVIEW_LARGE_HEIGHT)
            newHeight = CHATVIEW_LARGE_HEIGHT;
        
        self.chatView.frame = CGRectMake(CHATVIEW_CENTERX - (newWidth / 2), 0.0f, newWidth, newHeight);
        
        recognizer.scale = 1;
    }
}

- (void)userTapEvent:(UITapGestureRecognizer *)recognizer {
    [self takeScreenshotWithSave:YES];
}

- (void)configureForDialpad {
    PTNullPlaymate* nullPlaymate = [[PTNullPlaymate alloc] init];
    [self.chatView setLeftView:[[UIImageView alloc] initWithImage:nullPlaymate.userPhoto]];
    [self.chatView setRightView:[[UIImageView alloc] initWithImage:[PTUser currentUser].userPhoto]];
}

- (void)setLeftViewAsPlaceholder {
    [self.chatView setLeftView:[self playmatePlaceholderView]];
}

- (void)setCurrentUserPhoto {
    UIImage* myPhoto = [[PTUser currentUser] userPhoto];
    
    // If user photo is nil user the placeholder
    myPhoto = (myPhoto) ? [[PTUser currentUser] userPhoto] : [self placeholderImage];
    [self.chatView setLoadingImageForRightView:myPhoto];
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

- (void)disconnectOpenTokSession {
    [[PTVideoPhone sharedPhone] setSessionConnectedBlock:nil];
    [[PTVideoPhone sharedPhone] setSubscriberConnectedBlock:nil];
    [[PTVideoPhone sharedPhone] setPublisherDidStartStreamingBlock:nil];
    [[PTVideoPhone sharedPhone] disconnect];
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
    [self.chatView setLoadingImageForLeftView:self.playmate.userPhoto loadingText:self.playmate.username];
    
    UIImageView* myImageView = [[UIImageView alloc] initWithImage:[[PTUser currentUser] userPhoto]];
    [self.chatView setRightView:myImageView];
}

- (void)setPlaymate:(PTPlaymate *)aPlaymate {
    UIImageView* anImageview = [[UIImageView alloc] initWithImage:aPlaymate.userPhoto];
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
    dummyBackground.backgroundColor = [UIColor colorFromHex:@"#2E4957"];
    
    UIView *dummyContent = [[UIView alloc] initWithFrame:CGRectMake(7.0f, 7.0f, dummyFrame.size.width-14.0f, dummyFrame.size.height-14.0f)];
    dummyContent.backgroundColor = [UIColor clearColor];
    dummyContent.layer.cornerRadius = 10.0f;
    
    UIImageView *placeholderBuddy = [[UIImageView alloc] initWithFrame:dummyContent.bounds];
    placeholderBuddy.image = [UIImage imageNamed:@"placeholder-buddy"];
    [dummyContent addSubview:placeholderBuddy];
    
    [dummyBackground addSubview:dummyContent];
    return dummyBackground;
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