//
//  PTDialpadViewController.m
//  PlayTell
//
//  Created by Ricky Hussmann on 5/25/12.
//  Copyright (c) 2012 PlayTell. All rights reserved.
//

#import "Logging.h"
#import "PTAppDelegate.h"
#import "PTCheckForPlaydateRequest.h"
#import "PTConcretePlaymateFactory.h"
#import "PTDateViewController.h"
#import "PTDialpadViewController.h"
#import "PTPlayTellPusher.h"
#import "PTPlaydateCreateRequest.h"
#import "PTPlaydateDisconnectRequest.h"
#import "PTPlaymate.h"
#import "PTPlaymateButton.h"
#import "PTUser.h"
#import "TransitionController.h"
#import "PTPlaydateDetailsRequest.h"
#import "PTUsersGetStatusRequest.h"
#import "UIView+PlayTell.h"
#import "PTContactImportViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <QuartzCore/QuartzCore.h>

#define kAnimationRotateDeg 1.0

@interface PTDialpadViewController ()
@property (nonatomic, retain) PTPlaymateButton* selectedButton;
@property (nonatomic, retain) NSDictionary* userButtonHash;
@property (nonatomic, retain) PTPlaydate* requestedPlaydate;
@property (nonatomic, retain) UITapGestureRecognizer* cancelPlaydateRecognizer;
@property (nonatomic, retain) PTDateViewController* dateController;
@property (nonatomic, retain) AVAudioPlayer* audioPlayer;
@end

@implementation PTDialpadViewController
@synthesize scrollView;
@synthesize playmates;
@synthesize selectedButton;
@synthesize userButtonHash;
@synthesize requestedPlaydate;
@synthesize cancelPlaydateRecognizer;
@synthesize dateController;
@synthesize loadingView;
@synthesize audioPlayer;

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[PTPlayTellPusher sharedPusher] subscribeToRendezvousChannel];
    
    UIView* background = [self.view viewWithTag:666];
    CGRect backgroundFrame = self.view.frame;
    backgroundFrame.origin = CGPointZero;
    background.frame = backgroundFrame;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(pusherDidReceivePlaydateRequestNotification:)
                                                 name:PTPlayTellPusherDidReceivePlaydateRequestedEvent
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(pusherDidReceivePlaydateEndNotification:)
                                                 name:PTPlayTellPusherDidReceivePlaydateEndedEvent
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(pusherDidReceivePlaydateJoinedNotification:)
                                                 name:PTPlayTellPusherDidReceivePlaydateJoinedEvent
                                               object:nil];
    if (self.selectedButton) {
        [self deactivatePlaymateButton];
    }
    
    // Check now for any pending playdates, and register to be notified
    // when we come back to life if any were received while sleeping
    if (playdateRequestedViaPush != YES) {
        // Only check for pending playdates if one didn't come via push notification
        // Otherwise there's playdate collision!
        // More than likely, this will return the same playdate
        // BUT loading playdate id passed via push to be safe
        [self checkForPendingPlaydatesAndNotifyUser];
    } else {
        [self loadPlaydateDataFromPushNotification];
    }
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(checkForPendingPlaydateOnForegrounding:)
//                                                 name:UIApplicationWillEnterForegroundNotification
//                                               object:nil];
}

- (void)loadPlaydateDataFromPushNotification {
    // Request playdate details from server (using playdate id passed in via push notification)
    PTPlaydateDetailsRequest *playdateDetailsRequest = [[PTPlaydateDetailsRequest alloc] init];
    [playdateDetailsRequest playdateDetailsForPlaydateId:playdateRequestedViaPushId
                                               authToken:[[PTUser currentUser] authToken]
                                         playmateFactory:[PTConcretePlaymateFactory sharedFactory]
                                                 success:^(PTPlaydate *playdate) {
                                                     LogDebug(@"%@ received playdate on push: %@", NSStringFromSelector(_cmd), playdate);
                                                     self.requestedPlaydate = playdate;
                                                     dispatch_async(dispatch_get_main_queue(), ^() {
                                                         [self joinPlaydate];
                                                     });
                                                 }
                                                 failure:nil
     ];
    
    // Add a loading view to hide dialpad controls
    loadingView = [[UIView alloc] initWithFrame:self.view.bounds];
    UIImageView* loadingBG = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"date_bg.png"]];
    [loadingView addSubview:loadingBG];
    [self.view addSubview:loadingView];
    
    // Clean up for next dialpad view load (after playdate ends)
    playdateRequestedViaPush = NO;
}

- (void)setAwaitingPlaydateRequest:(NSInteger)playdateId {
    playdateRequestedViaPush = YES;
    playdateRequestedViaPushId = playdateId;
}

- (void)checkForPendingPlaydatesAndNotifyUser {
    // Check for any existing playdates
    PTUser* currentUser = [PTUser currentUser];
    PTCheckForPlaydateRequest* request = [[PTCheckForPlaydateRequest alloc] init];
    [request checkForExistingPlaydateForUser:currentUser.userID
                                   authToken:currentUser.authToken
                             playmateFactory:[PTConcretePlaymateFactory sharedFactory]
                                     success:^(PTPlaydate *playdate)
     {
         // TODO : need to refactor this and pusherDidReceivePlaydateRequestNotification: into
         // the same methods
         LogDebug(@"%@ received playdate on check: %@", NSStringFromSelector(_cmd), playdate);
         self.requestedPlaydate = playdate;
         [self notifyUserOfRequestedPlaydateAndSubscribeToPlaydateChannel];
     } failure:nil];
}

- (void)checkForPendingPlaydateOnForegrounding:(NSNotification*)note {
    if (playdateRequestedViaPush != YES) {
        [self checkForPendingPlaydatesAndNotifyUser];
    }
}

- (void)drawPlaymates {
    // TODO : revist the naming of these variables...
    NSUInteger numPlaymates = self.playmates.count + 1;
    
    CGFloat margin = 70;
    const CGFloat leftMargin = margin;
    const CGFloat rightMargin = margin;
    const CGFloat topMargin = 30;
    CGFloat rowSpacing = 10;
    const NSUInteger itemsPerRow = 4;
    const CGSize buttonSize = CGSizeMake(201, 151);
    
    CGFloat W = 1024;
    CGFloat interCellPadding = (W - leftMargin - rightMargin - ((CGFloat)itemsPerRow)*buttonSize.width)/(CGFloat)(itemsPerRow - 1);
    
    // Testing...
    rowSpacing = interCellPadding;
    NSUInteger numRows = numPlaymates/itemsPerRow + MIN(numPlaymates%itemsPerRow, 1);

    NSMutableDictionary* playmatesAndButtons = [NSMutableDictionary dictionary];
    for (int rowIndex = 0; rowIndex < numRows; rowIndex++) {
        for (int cellIndex = 0; cellIndex < itemsPerRow; cellIndex++) {
            NSUInteger playmateIndex = (rowIndex*itemsPerRow) + cellIndex;
            if (playmateIndex >= numPlaymates) {
                continue;
            }
            
            CGFloat cellX = leftMargin + ((CGFloat)cellIndex)*(buttonSize.width + interCellPadding);
            CGFloat cellY = topMargin + ((CGFloat)rowIndex)*(buttonSize.height + rowSpacing);
            
            UIButton* button;
            if (playmateIndex == numPlaymates - 1) {
                button = [UIButton buttonWithType:UIButtonTypeCustom];
                button.frame = CGRectMake(0, 0, buttonSize.width, buttonSize.height);
                [button setImage:[UIImage imageNamed:@"add-family.png"] forState:UIControlStateNormal];
                [playmatesAndButtons setObject:button
                                        forKey:@"AddUserButton"];
            } else {
                PTPlaymate* currentPlaymate = [self.playmates objectAtIndex:playmateIndex];
                button = [PTPlaymateButton playmateButtonWithPlaymate:currentPlaymate];
                [button addTarget:self action:@selector(playmateClicked:) forControlEvents:UIControlEventTouchUpInside];
                [playmatesAndButtons setObject:button
                                        forKey:[self stringFromUInt:currentPlaymate.userID]];
            }
            
            CGRect buttonFrame = button.frame;
            buttonFrame.origin = CGPointMake(cellX, cellY);
            button.frame = buttonFrame;
            [self.scrollView addSubview:button];
        }
    }
    self.userButtonHash = [NSDictionary dictionaryWithDictionary:playmatesAndButtons];

    self.scrollView.contentSize = CGSizeMake(W, topMargin + ((CGFloat)(numRows+1))*(rowSpacing + buttonSize.height));
    NSLog(@"Number of rows: %u", numRows);
    
    // Get a list of all playmate ids and get their current status
    NSMutableArray *ids = [[NSMutableArray alloc] init];
    for (NSString *key in [self.userButtonHash allKeys]) {
        if (![key isEqualToString:@"AddUserButton"]) {
            [ids addObject:key];
        }
    }
    PTUsersGetStatusRequest *usersGetStatusRequest = [[PTUsersGetStatusRequest alloc] init];
    [usersGetStatusRequest usersGetStatusForUserIds:ids
                                          authToken:[[PTUser currentUser] authToken]
                                            success:^(NSDictionary *result) {
                                                NSArray *statuses = [result objectForKey:@"status"];
                                                for (NSDictionary *userStatus in statuses) {
                                                    NSInteger user_id = [[userStatus objectForKey:@"id"] integerValue];
                                                    NSString *user_status = [userStatus objectForKey:@"status"];
                                                    PTPlaymateButton *button = [self.userButtonHash objectForKey:[self stringFromUInt:user_id]];
                                                    if (button == nil) {
                                                        return;
                                                    }
                                                    if ([user_status isEqualToString:@"pending"]) {
                                                        [button setPending];
                                                    } else if ([user_status isEqualToString:@"playdate"]) {
                                                        [button setPlaydating];
                                                    }
                                                }
                                            }
                                            failure:nil
     ];
}

- (void)playmateClicked:(PTPlaymateButton*)sender {
    LOGMETHOD;
    // Initiate playdate request
    [self joinPlaydate];

    PTPlaydateCreateRequest *playdateCreateRequest = [[PTPlaydateCreateRequest alloc] init];
    [playdateCreateRequest playdateCreateWithFriend:[NSNumber numberWithUnsignedInt:sender.playmate.userID]
                                          authToken:[[PTUser currentUser] authToken]
                                          onSuccess:^(NSDictionary *result)
     {
         LogInfo(@"playdateCreateWithFriend response: %@", result);
         PTPlaydate* aPlaydate = [[PTPlaydate alloc] initWithDictionary:result
                                                        playmateFactory:[PTConcretePlaymateFactory sharedFactory]];
         [self.dateController setPlaydate:aPlaydate];
         self.dateController = nil;
     } onFailure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
         LogError(@"playdateCreateWithFriend failed: %@", error);
     }
     ];
    LogInfo(@"Requesting playdate...");
}

- (void)joinPlaydate {
    LogTrace(@"Joining playdate: %@", self.requestedPlaydate);
    // Unsubscribe from rendezvous channel
    if ([[PTPlayTellPusher sharedPusher] isSubscribedToRendezvousChannel]) {
        [[PTPlayTellPusher sharedPusher] unsubscribeFromRendezvousChannel];
    }

    self.dateController = [[PTDateViewController alloc] initWithNibName:@"PTDateViewController"
                                                                 bundle:nil];
    PTAppDelegate* appDelegate = (PTAppDelegate*)[[UIApplication sharedApplication] delegate];
    [appDelegate.transitionController transitionToViewController:self.dateController withOptions:UIViewAnimationOptionTransitionCrossDissolve];

    if (self.requestedPlaydate) {
        [self.dateController setPlaydate:self.requestedPlaydate];
        self.requestedPlaydate = nil;
        self.dateController = nil;
    }

    [self endRinging];
}

- (void)endRinging {
    [self.audioPlayer stop];
}

- (NSString*)stringFromUInt:(NSUInteger)number {
    return [NSString stringWithFormat:@"%u", number];
}

- (void)pusherDidReceivePlaydateRequestNotification:(NSNotification*)note {
    PTPlaydate* playdate = [[note userInfo] valueForKey:PTPlaydateKey];
    LogDebug(@"%@ received playdate: %@", NSStringFromSelector(_cmd), playdate);

    // If the pusher event is intended for the current user,
    // notify the user of the event and subscribe to the playdate channel
    // for updates (potentially end playdate)
    if (playdate.playmate.userID == [[PTUser currentUser] userID]) {
        self.requestedPlaydate = playdate;
        [self notifyUserOfRequestedPlaydateAndSubscribeToPlaydateChannel];
    } else {
        // Mark players in this playdate as 'pending' in dialpad

        // Find appropriate playmate buttons
        PTPlaymateButton *button_player1 = [self.userButtonHash objectForKey:[self stringFromUInt:playdate.initiator.userID]];
        PTPlaymateButton *button_player2 = [self.userButtonHash objectForKey:[self stringFromUInt:playdate.playmate.userID]];
        if (button_player1) {
            [button_player1 setPlaydating];
        }
        if (button_player2) {
            [button_player2 setPlaydating];
        }
    }
}

- (void)pusherDidReceivePlaydateJoinedNotification:(NSNotification*)note {
    PTPlaydate* playdate = [[note userInfo] valueForKey:PTPlaydateKey];
    LogDebug(@"%@ Playdate Joined: %@", NSStringFromSelector(_cmd), playdate);
    
    // Make sure current user didn't participate in this playdate
    if (playdate.playmate.userID != [[PTUser currentUser] userID] && playdate.initiator.userID != [[PTUser currentUser] userID]) {
        // Mark players in this playdate as 'in playdate' in dialpad
        
        // Find appropriate playmate buttons
        PTPlaymateButton *button_player1 = [self.userButtonHash objectForKey:[self stringFromUInt:playdate.initiator.userID]];
        PTPlaymateButton *button_player2 = [self.userButtonHash objectForKey:[self stringFromUInt:playdate.playmate.userID]];
        if (button_player1) {
            [button_player1 setPlaydating];
        }
        if (button_player2) {
            [button_player2 setPlaydating];
        }
    }
}

- (void)pusherDidReceivePlaydateEndNotification:(NSNotification*)note {
    PTPlaydate* playdate = [[note userInfo] valueForKey:PTPlaydateKey];
    LogDebug(@"%@ Playdate Ended: %@", NSStringFromSelector(_cmd), playdate);
    
    // Make sure current user didn't participate in this playdate
    if (playdate.playmate.userID != [[PTUser currentUser] userID] && playdate.initiator.userID != [[PTUser currentUser] userID]) {
        // Mark players in this playdate as active in dialpad
        
        // Find appropriate playmate buttons
        PTPlaymateButton *button_player1 = [self.userButtonHash objectForKey:[self stringFromUInt:playdate.initiator.userID]];
        PTPlaymateButton *button_player2 = [self.userButtonHash objectForKey:[self stringFromUInt:playdate.playmate.userID]];
        if (button_player1) {
            [button_player1 setNormal];
        }
        if (button_player2) {
            [button_player2 setNormal];
        }
    }
}

- (void)notifyUserOfRequestedPlaydateAndSubscribeToPlaydateChannel {
    PTPlaymateButton* button = [self.userButtonHash valueForKey:[self stringFromUInt:self.requestedPlaydate.initiator.userID]];
    [self activatePlaymateButton:button];
    [self beginRinging];

    [[PTPlayTellPusher sharedPusher] unsubscribeFromRendezvousChannel];
    [[PTPlayTellPusher sharedPusher] subscribeToPlaydateChannel:self.requestedPlaydate.pusherChannelName];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playmateEndedPlaydate:)
                                                 name:@"PlayDateEndPlaydate"
                                               object:nil];
}

- (void)activatePlaymateButton:(PTPlaymateButton*)button {
    CGRect newFrame = [self.view convertRect:button.frame fromView:button.superview];
    button.frame = newFrame;
    [self.view addSubview:button];

    UIView* backgroundView = [[UIView alloc] initWithFrame:self.view.bounds];
    backgroundView.backgroundColor = [UIColor blackColor];
    backgroundView.alpha = 0.0;
    backgroundView.tag = 669;

    [self.view insertSubview:backgroundView belowSubview:button];
    [UIView animateWithDuration:0.7 animations:^{
        backgroundView.alpha = 0.7;
    }];

//    [self.scrollView bringSubviewToFront:button];
    self.selectedButton = button;
    button.isActivated = YES;

    [button removeTarget:self action:@selector(playmateClicked:) forControlEvents:UIControlEventTouchUpInside];
    [button addTarget:self action:@selector(joinPlaydate) forControlEvents:UIControlEventTouchUpInside];
    
    [UIView animateWithDuration:0.5 animations:^{
        [button setRequestingPlaydate];
    }];
    [self shakeButton:button];

    self.cancelPlaydateRecognizer.enabled = YES;
}

- (void)beginRinging {
    [self.audioPlayer play];
}

- (void)playmateEndedPlaydate:(NSNotification*)note {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"PlayDateEndPlaydate"
                                                  object:nil];
    [[PTPlayTellPusher sharedPusher] unsubscribeFromPlaydateChannel:self.requestedPlaydate.pusherChannelName];
    [[PTPlayTellPusher sharedPusher] subscribeToRendezvousChannel];
    [self deactivatePlaymateButton];
    [self endRinging];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self deactivatePlaymateButton];
}

- (void)deactivatePlaymateButton {
    self.selectedButton.transform = CGAffineTransformIdentity;
    [self.selectedButton.layer removeAllAnimations];
    self.selectedButton.isActivated = NO;
    [self.selectedButton resetButton];

    CGRect newFrame = [self.scrollView convertRect:self.selectedButton.frame fromView:self.view];
    self.selectedButton.frame = newFrame;
    [self.scrollView addSubview:self.selectedButton];

    [self.selectedButton removeTarget:self action:@selector(joinPlaydate) forControlEvents:UIControlEventTouchUpInside];
    [self.selectedButton addTarget:self action:@selector(playmateClicked:) forControlEvents:UIControlEventTouchUpInside];

    self.selectedButton = nil;

    UIView* backgroundView = [self.view viewWithTag:669];
    [backgroundView removeFromSuperview];

    self.cancelPlaydateRecognizer.enabled = NO;
}

- (void)loadView {
    [super loadView];
    self.view.frame = CGRectMake(0, 0, 1024, 748);

    UIImage* backgroundImage = [UIImage imageNamed:@"date_bg.png"];
    UIImageView* background = [[UIImageView alloc] initWithImage:backgroundImage];
    background.tag = 666;
    [self.view addSubview:background];

    NSString* welcomeText = @"WHO WILL YOU PLAY WITH TODAY?";
    CGSize labelSize = [welcomeText sizeWithFont:[self welcomeTextFont]
                               constrainedToSize:CGSizeMake(1024, CGFLOAT_MAX)];
    CGRect welcomeLabelRect;
    welcomeLabelRect = CGRectMake(1024.0/2.0 - labelSize.width/2.0, 55,
                                  labelSize.width, labelSize.height);
    UILabel* welcomeLabel = [[UILabel alloc] initWithFrame:welcomeLabelRect];
    welcomeLabel.text = welcomeText;
    welcomeLabel.font = [self welcomeTextFont];
    welcomeLabel.textColor = [UIColor redColor];
    welcomeLabel.backgroundColor = [UIColor clearColor];
    [self.view addSubview:welcomeLabel];

    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 115, 1024, 633)];
    [self.view addSubview:self.scrollView];

    self.cancelPlaydateRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    [self.view addGestureRecognizer:self.cancelPlaydateRecognizer];
    self.cancelPlaydateRecognizer.enabled = NO;
    self.cancelPlaydateRecognizer.delegate = self;

    [self drawPlaymates];
    
     // TEMP
     UIButton *contactButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
     [contactButton setTitle:@"Import Contacts" forState:UIControlStateNormal];
     contactButton.frame = CGRectMake(20.0f, 695.0f, 170.0f, 35.0f);
     [contactButton addTarget:self action:@selector(loadContactImportController:) forControlEvents:UIControlEventTouchUpInside];
     [self.view addSubview:contactButton];
 }

- (void)loadContactImportController:(id)sender {
     PTContactImportViewController *contactImportViewController = [[PTContactImportViewController alloc] initWithNibName:@"PTContactImportViewController" bundle:nil];
     UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:contactImportViewController];
     
     PTAppDelegate* appDelegate = (PTAppDelegate*)[[UIApplication sharedApplication] delegate];
     [appDelegate.transitionController transitionToViewController:navController withOptions:UIViewAnimationOptionTransitionCrossDissolve];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupRinger];
}

- (void)setupRinger {
    NSError *playerError;
    NSURL *ringtone = [[NSBundle mainBundle] URLForResource:@"ringtone-connecting" withExtension:@"mp3"];
    AVAudioPlayer *thePlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:ringtone error:&playerError];
    thePlayer.volume = 0.25;
    thePlayer.numberOfLoops = 4;
    self.audioPlayer = thePlayer;
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (UIFont*)welcomeTextFont {
    return [UIFont fontWithName:@"TeluguSangamMN" size:26.0];
}

- (void)viewTapped:(UIGestureRecognizer*)recognizers {
    LOGMETHOD;
    [self deactivatePlaymateButton];
    [self endRinging];
    PTPlaydateDisconnectRequest *playdateDisconnectRequest = [[PTPlaydateDisconnectRequest alloc] init];
    [playdateDisconnectRequest playdateDisconnectWithPlaydateId:[NSNumber numberWithInt:self.requestedPlaydate.playdateID]
                                                      authToken:[[PTUser currentUser] authToken]
                                                      onSuccess:nil
                                                      onFailure:nil
     ];
    self.requestedPlaydate = nil;
}

- (void)shakeButton:(PTPlaymateButton *)sender {
    // Begin snip
    NSInteger randomInt = arc4random()%500;
    float r = (randomInt/500.0)+0.5;

    CGAffineTransform leftWobble = CGAffineTransformMakeRotation(degreesToRadians( (kAnimationRotateDeg * -1.0) - r ));
    CGAffineTransform rightWobble = CGAffineTransformMakeRotation(degreesToRadians( kAnimationRotateDeg + r ));

    sender.transform = leftWobble;  // starting point

    [[sender layer] setAnchorPoint:CGPointMake(0.5, 0.5)];

    [UIView animateWithDuration:0.1
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse
                     animations:^{
                         [UIView setAnimationRepeatCount:NSNotFound];
                         sender.transform = rightWobble; }
                     completion:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

#pragma mark - UIGestureRecognizerDelegate methods
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    CGPoint touchLocation = [touch locationInView:self.view];

    return !CGRectContainsPoint(self.selectedButton.frame, touchLocation);
}

@end
