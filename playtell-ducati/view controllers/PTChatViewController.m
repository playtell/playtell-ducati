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
#import "PTPlaydatePhotoCreateRequest.h"
#import "PTPlayTellPusher.h"
#import "PTSpinnerView.h"
#import "PTUser.h"

#import "PTPlaydate+InitatorChecking.h"
#import "UIView+PlayTell.h"
#import "UIColor+ColorFromHex.h"
#import "UIImage+Resize.h"

#import <MediaPlayer/MediaPlayer.h>
#import <QuartzCore/QuartzCore.h>

#define CHATVIEW_CENTERX        512.0
#define CHATVIEW_LARGE_HEIGHT   300.0
#define CHATVIEW_LARGE_WIDTH    400.0
#define CHATVIEW_SMALL_HEIGHT   150.0
#define CHATVIEW_SMALL_WIDTH    200.0
#define CHATVIEW_PADDING        8.0
#define CHATVIEW_MARGIN         8.0
#define OFFSCREEN_SIZE          100.0

@interface PTChatViewController ()
@property (nonatomic, strong) PTVideoPhone* videoPhone;
@property (nonatomic, strong) MPMoviePlayerController* movieController;
@property (nonatomic, assign) BOOL restrictSizeToSmall;
@property (nonatomic, strong) UIButton *btnFullscreen;
@property (nonatomic, strong) PTFullscreenChatView *fullscreenView;
@end

@implementation PTChatViewController
@synthesize leftView, rightView, videoPhone, playdate, playmate;
@synthesize movieController;
@synthesize restrictSizeToSmall;
@synthesize btnFullscreen;
@synthesize fullscreenView;

NSTimer *screenshotTimer;
CGRect fullscreenOffscreenRect;
CGRect fullscreenOnscreenRect;
bool inFullscreen;
UISwipeGestureRecognizer *swipeUpRecognizer;
UISwipeGestureRecognizer *swipeDownRecognizer;
UIPinchGestureRecognizer *pinchRecognizer;
UITapGestureRecognizer *tapRecognizer;
CGRect originalLeftBounds;
CGRect originalRightBounds;

- (void)playMovieURLInLeftPane:(NSURL*)movieURL {
    self.movieController.contentURL = movieURL;
    self.movieController.scalingMode = MPMovieScalingModeAspectFit;
    self.movieController.controlStyle = MPMovieControlStyleNone;
    [self.leftView setView:self.movieController.view];
    [self.movieController play];
}

- (void)stopPlayingMovies {
    [self.movieController stop];
}

- (id)init {
    if (self = [super init]) {
        self.view = [[PTChatHUDParentView alloc] init];
        
        inFullscreen = NO;

        CGFloat widthWithPadding = (2.0f * CHATVIEW_PADDING) + CHATVIEW_SMALL_WIDTH; // Account for padding around chat view
        CGFloat heightWithPadding = CHATVIEW_PADDING + CHATVIEW_SMALL_HEIGHT;

        self.leftView = [[PTChatHUDView alloc] initWithFrame:CGRectMake(CHATVIEW_CENTERX - widthWithPadding + (CHATVIEW_PADDING / 2.0f), 0.0f, widthWithPadding, heightWithPadding)];
        self.rightView = [[PTChatHUDView alloc] initWithFrame:CGRectMake(CHATVIEW_CENTERX - (CHATVIEW_PADDING / 2.0f), 0.0f, widthWithPadding, heightWithPadding)];
        [self.view addSubview:self.leftView];
        [self.view addSubview:self.rightView];
        
        // Create the button to go to fullscreen mode
        UIImage *imgFullscreen = [UIImage imageNamed:@"full-screen.png"];
        UIImage *imgFullscreenPress = [UIImage imageNamed:@"full-screen-press.png"];
        btnFullscreen = [[UIButton alloc] initWithFrame:CGRectMake(rightView.frame.origin.x + rightView.frame.size.width + CHATVIEW_PADDING, rightView.frame.origin.y, imgFullscreen.size.width, imgFullscreen.size.height)];
        [btnFullscreen setBackgroundImage:imgFullscreen forState:UIControlStateNormal];
        [btnFullscreen setBackgroundImage:imgFullscreenPress forState:UIControlStateHighlighted];
        btnFullscreen.alpha = 0.0f;
        [btnFullscreen addTarget:self action:@selector(fullscreenButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btnFullscreen];
        
        // Create the shim view
        fullscreenOffscreenRect = CGRectMake(CHATVIEW_CENTERX - (OFFSCREEN_SIZE / 2), -OFFSCREEN_SIZE, OFFSCREEN_SIZE, OFFSCREEN_SIZE);
        fullscreenOnscreenRect = CGRectMake(0.0f, 0.0f, 1024.0f, 768.0f);
        fullscreenView = [[PTFullscreenChatView alloc] init];
        fullscreenView.delegate = self;
        fullscreenView.frame = fullscreenOffscreenRect;
        [self.view addSubview:fullscreenView];
        
        self.movieController = [[MPMoviePlayerController alloc] initWithContentURL:nil];
        self.restrictSizeToSmall = YES;
        
        // Create the gesture recognizers
        swipeUpRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(userSwipeUpEvent:)];
        swipeUpRecognizer.direction = UISwipeGestureRecognizerDirectionUp;
        swipeDownRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(userSwipeDownEvent:)];
        swipeDownRecognizer.direction = UISwipeGestureRecognizerDirectionDown;
        pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(userPinchEvent:)];
        tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userTapEvent:)];
        tapRecognizer.numberOfTapsRequired = 1;
        
        // Set self to be the delegate for all gesture recognizers
        swipeUpRecognizer.delegate = self;
        swipeDownRecognizer.delegate = self;
        pinchRecognizer.delegate = self;
        tapRecognizer.delegate = self;
        
        // Add the gesture recognizers to the views
        [self.view addGestureRecognizer:swipeUpRecognizer];
        [self.view addGestureRecognizer:swipeDownRecognizer];
        [self.view addGestureRecognizer:pinchRecognizer];
        [self.view addGestureRecognizer:tapRecognizer];
        
        // Notifications for when playmate uses fullscreen
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playmateStartedFullscreen) name:@"FullscreenStart" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playmateEndedFullscreen) name:@"FullscreenEnd" object:nil];
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
        // Get images from left and right chat HUDs
        UIImage *leftScreen = [self.leftView.contentView screenshotWithSave:NO];
        UIImage *rightScreen = [self.rightView.contentView screenshotWithSave:NO];
        UIImage *leftVideo = [self.leftView.opentokView screenshotWithSave:NO];
        UIImage *rightVideo = [self.rightView.opentokView screenshotWithSave:NO];
        
        // Resize if chatview was expanded
        if (leftScreen.size.width > CHATVIEW_SMALL_WIDTH) {
            leftScreen = [leftScreen scaleProportionallyToSize:CGSizeMake(CHATVIEW_SMALL_WIDTH, CHATVIEW_SMALL_HEIGHT)];
            rightScreen = [rightScreen scaleProportionallyToSize:CGSizeMake(CHATVIEW_SMALL_WIDTH, CHATVIEW_SMALL_HEIGHT)];
            leftVideo = [leftVideo scaleProportionallyToSize:CGSizeMake(CHATVIEW_SMALL_WIDTH, CHATVIEW_SMALL_HEIGHT)];
            rightVideo = [rightVideo scaleProportionallyToSize:CGSizeMake(CHATVIEW_SMALL_WIDTH, CHATVIEW_SMALL_HEIGHT)];
        }
        
        // Merge the two images
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(400.0f, 150.0f), NO, 0);
        [leftScreen drawAtPoint:CGPointMake(0.0f, 0.0f)];
        [rightScreen drawAtPoint:CGPointMake(200.0f, 0.0f)];
        [leftVideo drawAtPoint:CGPointMake(0.0f, 0.0f)];
        [rightVideo drawAtPoint:CGPointMake(200.0f, 0.0f)];
        UIImage *screenshot = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        // Save to photo roll?
        if (saveToCameraRoll) {
            UIImageWriteToSavedPhotosAlbum(screenshot, nil, nil, nil);
        }
        
        // Save to the server (only if logged in)
        if ([PTUser currentUser].isLoggedIn == YES) {
            PTPlaydatePhotoCreateRequest *photoCreateRequest = [[PTPlaydatePhotoCreateRequest alloc] init];
            [photoCreateRequest playdatePhotoCreateWithUserId:[PTUser currentUser].userID
                                                   playdateId:self.playdate.playdateID
                                                        photo:screenshot
                                                      success:^(NSDictionary *result) {
                                                          //NSLog(@"Playdate photo successfully uploaded.");
                                                      } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                          NSLog(@"Playdate photo creation failure!! %@ - %@", error, JSON);
                                                      }];
        }
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

- (void)playmateStartedFullscreen {
    if (self.restrictSizeToSmall)
        return;
    
    [self showFullscreenChat:YES];
}

- (void)playmateEndedFullscreen {
    if (self.restrictSizeToSmall)
        return;
    
    [self hideFullscreenChat:YES];
}

- (void)fullscreenButtonPressed {
    [self showFullscreenChat:YES];
    
    // Send a notification to pusher
    [[PTPlayTellPusher sharedPusher] emitEventNamed:@"client-fullscreen_start"
                                               data:[[NSDictionary alloc] init]
                                            channel:playdate.pusherChannelName];
}

- (void)hideFullscreenChat:(BOOL)animated {
    if (!inFullscreen) {
        return;
    }
    inFullscreen = NO;
    
    float animationTime = 0.0f;
    if (animated) {
        animationTime = 1.0f;
    }
    
    [UIView animateWithDuration:animationTime animations:^{
        fullscreenView.leftView.alpha = 0.0f;
        fullscreenView.rightView.alpha = 0.0f;
    } completion:^(BOOL finished) {
        // Reset the original bounds
        UIView *leftVideo = [[PTVideoPhone sharedPhone] currentSubscriberView];
        leftVideo.bounds = originalLeftBounds;
        UIView *rightVideo = [[PTVideoPhone sharedPhone] currentPublisherView];
        rightVideo.bounds = originalRightBounds;
        
        // Remove the videos from the fullscreen view
        [fullscreenView.leftView removeAllSubviews];
        [fullscreenView.rightView removeAllSubviews];
        
        // Set the opentok views
        [leftView setOpentokVideoView:leftVideo];
        [rightView setOpentokVideoView:rightVideo];
        
        [UIView animateWithDuration:animationTime animations:^{
            fullscreenView.frame = fullscreenOffscreenRect;
        }];
    }];
}

- (void)resetFullscreenButtonLocation {
    // Set the location of the fullscreen button
    btnFullscreen.frame = CGRectMake(self.rightView.frame.origin.x + self.rightView.frame.size.width + CHATVIEW_PADDING, rightView.frame.origin.y, btnFullscreen.frame.size.width, btnFullscreen.frame.size.height);
}

- (void)showFullscreenChat:(BOOL)animated {
    inFullscreen = YES;
    float animationTime = 0.0f;
    if (animated) {
        animationTime = 1.0f;
    }
    
    [UIView animateWithDuration:animationTime animations:^{
        fullscreenView.frame = fullscreenOnscreenRect;
    } completion:^(BOOL finished) {
        // Save the original bounds so we can put them back when fullscreen ends
        UIView *leftVideo = [[PTVideoPhone sharedPhone] currentSubscriberView];
        originalLeftBounds = leftVideo.bounds;
        UIView *rightVideo = [[PTVideoPhone sharedPhone] currentPublisherView];
        originalRightBounds = rightVideo.bounds;
        
        // Add the videos to the fullscreen view
        leftVideo.frame = CGRectMake(0.0f, 0.0f, fullscreenView.leftView.frame.size.width, fullscreenView.leftView.frame.size.height);
        [fullscreenView.leftView addSubview:leftVideo];
        rightVideo.frame = CGRectMake(0.0f, 0.0f, fullscreenView.rightView.frame.size.width, fullscreenView.rightView.frame.size.height);
        [fullscreenView.rightView addSubview:rightVideo];
        
        [UIView animateWithDuration:animationTime animations:^{
            fullscreenView.leftView.alpha = 1.0f;
            fullscreenView.rightView.alpha = 1.0f;
        }];
    }];
}

- (void)restrictToSmallSize:(BOOL)shouldRestrict {
    if (shouldRestrict) {
        // Hide fullscreen view
        [self hideFullscreenChat:NO];
        btnFullscreen.alpha = 0.0f;
        
        // Calculate width and height
        CGFloat widthWithPadding = (2.0f * CHATVIEW_PADDING) + CHATVIEW_SMALL_WIDTH; // Account for padding around chat view
        CGFloat heightWithPadding = CHATVIEW_PADDING + CHATVIEW_SMALL_HEIGHT;

        self.leftView.frame = CGRectMake(CHATVIEW_CENTERX - widthWithPadding + (CHATVIEW_PADDING / 2.0f), 0.0f, widthWithPadding, heightWithPadding);
        self.rightView.frame = CGRectMake(CHATVIEW_CENTERX - (CHATVIEW_PADDING / 2.0f), 0.0f, widthWithPadding, heightWithPadding);
        
        [self resetFullscreenButtonLocation];
    } else {
        [UIView animateWithDuration:0.5f animations:^{
            btnFullscreen.alpha = 1.0f;
        }];
    }
    
    self.restrictSizeToSmall = shouldRestrict;
}

- (void)userSwipeDownEvent:(UISwipeGestureRecognizer *)recognizer {
    if (self.restrictSizeToSmall)
        return;
    
    // Calculate final width and height
    CGFloat widthWithPadding = (2.0f * CHATVIEW_PADDING) + CHATVIEW_LARGE_WIDTH; // Account for padding around chat view
    CGFloat heightWithPadding = CHATVIEW_PADDING + CHATVIEW_LARGE_HEIGHT;
    
    self.leftView.frame = CGRectMake(CHATVIEW_CENTERX - widthWithPadding + (CHATVIEW_PADDING / 2.0f), 0.0f, widthWithPadding, heightWithPadding);
    self.rightView.frame = CGRectMake(CHATVIEW_CENTERX - (CHATVIEW_PADDING / 2.0f), 0.0f, widthWithPadding, heightWithPadding);
    
    [self resetFullscreenButtonLocation];
}

- (void)userSwipeUpEvent:(UISwipeGestureRecognizer *)recognizer {
    if (self.restrictSizeToSmall)
        return;
    
    // Calculate width and height
    CGFloat widthWithPadding = (2.0f * CHATVIEW_PADDING) + CHATVIEW_SMALL_WIDTH; // Account for padding around chat view
    CGFloat heightWithPadding = CHATVIEW_PADDING + CHATVIEW_SMALL_HEIGHT;
    
    self.leftView.frame = CGRectMake(CHATVIEW_CENTERX - widthWithPadding + (CHATVIEW_PADDING / 2.0f), 0.0f, widthWithPadding, heightWithPadding);
    self.rightView.frame = CGRectMake(CHATVIEW_CENTERX - (CHATVIEW_PADDING / 2.0f), 0.0f, widthWithPadding, heightWithPadding);
    
    [self resetFullscreenButtonLocation];
}

- (void)userPinchEvent:(UIPinchGestureRecognizer *)recognizer {
    if (self.restrictSizeToSmall)
        return;
    
    if (recognizer.state == UIGestureRecognizerStateBegan ||
        recognizer.state == UIGestureRecognizerStateChanged) {
        CGFloat scale = recognizer.scale;
        
        // Min/max width
        float newWidth = (self.leftView.frame.size.width - (2.0f * CHATVIEW_PADDING)) * scale;
        if (newWidth < CHATVIEW_SMALL_WIDTH) {
            newWidth = CHATVIEW_SMALL_WIDTH;
        }
        
        if (newWidth > CHATVIEW_LARGE_WIDTH) {
            newWidth = CHATVIEW_LARGE_WIDTH;
        }
        
        // Min/max height
        float newHeight = (self.leftView.frame.size.height - CHATVIEW_PADDING) * scale;
        if (newHeight < CHATVIEW_SMALL_HEIGHT) {
            newHeight = CHATVIEW_SMALL_HEIGHT;
        }
        if (newHeight > CHATVIEW_LARGE_HEIGHT) {
            newHeight = CHATVIEW_LARGE_HEIGHT;
        }
        
        // Calculate final width and height
        CGFloat widthWithPadding = (2.0f * CHATVIEW_PADDING) + newWidth; // Account for padding around chat view
        CGFloat heightWithPadding = CHATVIEW_PADDING + newHeight;
        
        self.leftView.frame = CGRectMake(CHATVIEW_CENTERX - widthWithPadding + (CHATVIEW_PADDING / 2.0f), 0.0f, widthWithPadding, heightWithPadding);
        self.rightView.frame = CGRectMake(CHATVIEW_CENTERX - (CHATVIEW_PADDING / 2.0f), 0.0f, widthWithPadding, heightWithPadding);
        
        [self resetFullscreenButtonLocation];

        recognizer.scale = 1;
    }
}

- (void)userTapEvent:(UITapGestureRecognizer *)recognizer {
    [self takeScreenshotWithSave:YES];
}

- (void)configureForDialpad {
    PTNullPlaymate* nullPlaymate = [[PTNullPlaymate alloc] init];
    [self.leftView setView:[[UIImageView alloc] initWithImage:nullPlaymate.userPhoto]];
    [self.rightView setView:[[UIImageView alloc] initWithImage:[PTUser currentUser].userPhoto]];
}

- (void)setLeftViewAsPlaceholder {
    [self.leftView setView:[self playmatePlaceholderView]];
}

- (void)setCurrentUserPhoto {
    UIImage* myPhoto = [[PTUser currentUser] userPhoto];
    
    // If user photo is nil user the placeholder
    myPhoto = (myPhoto) ? [[PTUser currentUser] userPhoto] : [self placeholderImage];
    [self.rightView setLoadingImageForView:myPhoto];
}

- (void)connectToOpenTokSession {
    NSString *myToken, *mySession;
    if ([[PTUser currentUser] isLoggedIn]) {
        [[PTVideoPhone sharedPhone] setSessionConnectedBlock:^(OTStream *subscriberStream, OTSession *session, BOOL isSelf) {
            LogDebug(@"Session connected");
        }];
        [[PTVideoPhone sharedPhone] setSubscriberConnectedBlock:^(OTSubscriber* subscriber) {
            LogDebug(@"Subscriber connected");
            [self.leftView setOpentokVideoView:subscriber.view];
        }];

        myToken = ([self.playdate isUserIDInitiator:[[PTUser currentUser] userID]]) ?
        self.playdate.initiatorTokboxToken : self.playdate.playmateTokboxToken;
        
        mySession = self.playdate.tokboxSessionID;
        
        // Begin duplicated code!
        [[PTVideoPhone sharedPhone] setPublisherDidStartStreamingBlock:^(OTPublisher *aPublisher) {
            LogDebug(@"Publisher started streaming");
            [self.rightView setOpentokVideoView:aPublisher.view];
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
         [[PTVideoPhone sharedPhone] setPublisherDidStartStreamingBlock:^(OTPublisher *aPublisher) {
             LogDebug(@"Publisher started streaming");
             [self.rightView setView:aPublisher.view];
         }];
         [[PTVideoPhone sharedPhone] setPublisherDidStopStreamingBlock:^(OTPublisher *aPublisher) {
             [self setCurrentUserPhoto];
         }];
         [[PTVideoPhone sharedPhone] connectToSession:openTokSession
                                            withToken:openTokToken
                                              success:^(OTPublisher* publisher)
          {
              LogDebug(@"Connected to OpenTok session");
          } failure:^(NSError* error) {
              LogError(@"Error connecting to OpenTok session: %@", error);
          }];
     } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
         LogError(@"Error requesting TokBox token: %@", error);
     }];
}

- (void)setupPlaymatePlaceholderImages {
    LOGMETHOD;
    [self.leftView setLoadingImageForView:self.playmate.userPhoto];// loadingText:self.playmate.username];
    
    UIImageView* myImageView = [[UIImageView alloc] initWithImage:[[PTUser currentUser] userPhoto]];
    [self.rightView setView:myImageView];
}

- (void)setPlaymate:(PTPlaymate *)aPlaymate {
    UIImageView* anImageview = [[UIImageView alloc] initWithImage:aPlaymate.userPhoto];
    anImageview.contentMode = UIViewContentModeScaleAspectFit;
    [self.leftView setView:anImageview];
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
    PTSpinnerView *spinner = [[PTSpinnerView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 75.0f, 75.0f)];
    spinner.center = opacityView.center;
    spinner.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    [spinner startSpinning];
    [opacityView addSubview:spinner];
    
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
    
    [self.leftView setView:anImageView];
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

- (UIImage*)placeholderImage {
    return [UIImage imageNamed:@"profile_default_2.png"];
}

#pragma mark - UIGestureRecognizerDelegate methods

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
       shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isKindOfClass:[UIControl class]]) {
        // we touched a button, slider, or other UIControl
        return NO; // ignore the touch
    }
    return YES; // handle the touch
}

#pragma mark - PTFullscreenChatViewDelegate methods

- (void)fullscreenChatViewShouldClose:(UIView *)closingView {
    [self hideFullscreenChat:YES];
    
    // Send a notification to pusher
    [[PTPlayTellPusher sharedPusher] emitEventNamed:@"client-fullscreen_end"
                                               data:[[NSDictionary alloc] init]
                                            channel:playdate.pusherChannelName];
}

#pragma mark - Game-related methods

- (void)setActiveTurnToLeftChatView {
    self.rightView.layer.zPosition = 0;
    [self.rightView hideBorder];
    self.leftView.layer.zPosition = 1;
    [self.leftView showBorder];
    
    // Pulsate with color
    [self.leftView pulsateBorderWithColor:[UIColor colorFromHex:@"#f48511"]];
}

- (void)setActiveTurnToRightChatView {
    self.leftView.layer.zPosition = 0;
    [self.leftView hideBorder];
    self.rightView.layer.zPosition = 1;
    [self.rightView showBorder];

    // Pulsate with color
    [self.rightView pulsateBorderWithColor:[UIColor colorFromHex:@"#17a84b"]];
}

- (void)hideAllBorders {
    self.leftView.layer.zPosition = 0;
    [self.leftView hideBorder];
    self.rightView.layer.zPosition = 0;
    [self.rightView hideBorder];
}

@end