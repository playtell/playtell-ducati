
//
//  PTDialpadViewController.m
//  PlayTell
//
//  Created by Ricky Hussmann on 5/25/12.
//  Copyright (c) 2012 PlayTell. All rights reserved.
//

#import "AFImageRequestOperation.h"
#import "Logging.h"
#import "PTAllPostcardsRequest.h"
#import "PTAnalytics.h"
#import "PTAppDelegate.h"
#import "PTBadgeButton.h"
#import "PTChatViewController.h"
#import "PTCheckForPlaydateRequest.h"
#import "PTConcretePlaymateFactory.h"
#import "PTContactSelectViewController.h"
#import "PTDateViewController.h"
#import "PTDialpadViewController.h"
#import "PTFriendshipAcceptRequest.h"
#import "PTFriendshipDeclineRequest.h"
#import "PTNewUserNavigationController.h"
#import "PTNullPlaymate.h"
#import "PTNumNewPostcardsRequest.h"
#import "PTPlayTellPusher.h"
#import "PTPlaydateCreateRequest.h"
#import "PTPlaydateDetailsRequest.h"
#import "PTPlaydateDisconnectRequest.h"
#import "PTPlaymate.h"
#import "PTPlaymateButton.h"
#import "PTPlaymateView.h"
#import "PTPlaymateAddView.h"
#import "PTPostcard.h"
#import "PTSettingsViewController.h"
#import "PTSoloUser.h"
#import "PTSpinnerView.h"
#import "PTUser.h"
#import "PTUsersGetStatusRequest.h"
#import "TransitionController.h"

#import "PTPlaydate+InitatorChecking.h"
#import "UIColor+ColorFromHex.h"
#import "UIView+PlayTell.h"

#import <AddressBook/AddressBook.h>
#import <AVFoundation/AVFoundation.h>
#import <QuartzCore/QuartzCore.h>

#define kAnimationRotateDeg 1.0

@interface PTDialpadViewController ()
@property (nonatomic, retain) PTPlaymateView* selectedPlaymateView;
@property (nonatomic, retain) NSMutableDictionary* playmateViews;
@property (nonatomic, retain) PTPlaydate* requestedPlaydate;
@property (nonatomic, retain) UITapGestureRecognizer* cancelPlaydateRecognizer;
@property (nonatomic, retain) PTDateViewController* dateController;
@property (nonatomic, retain) AVAudioPlayer* audioPlayer;
@property (nonatomic, retain) PTChatViewController* chatController;
@property (nonatomic, assign) UIBackgroundTaskIdentifier backgroundTask;
@property (nonatomic, retain) PTBadgeButton* postcardButton;
@property (nonatomic, retain) UIButton *settingsButton;
@end

@implementation PTDialpadViewController
@synthesize scrollView;
@synthesize playmates;
@synthesize selectedPlaymateView;
@synthesize playmateViews;
@synthesize requestedPlaydate;
@synthesize cancelPlaydateRecognizer;
@synthesize dateController;
@synthesize loadingView;
@synthesize playdateToIgnore;
@synthesize audioPlayer;
@synthesize chatController;
@synthesize backgroundTask;
@synthesize postcardButton;
@synthesize settingsButton;

BOOL playdateStarting;
BOOL postcardsShown;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Bypass OpenTok permission dialog
        NSString *otPublisherAccepted = [[NSUserDefaults standardUserDefaults] stringForKey:@"opentok.publisher.accepted"];
        if (otPublisherAccepted == nil) {
            [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"opentok.publisher.accepted"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        
        postcardsShown = NO;
    }
    return self;
}

- (void)loadView {
    [super loadView];
    self.view.frame = CGRectMake(0, 0, 1024, 748);
    
    UIImage* backgroundImage = [UIImage imageNamed:@"date_bg.png"];
    background = [[UIImageView alloc] initWithImage:backgroundImage];
    background.tag = 666;
    background.layer.masksToBounds = NO;
    background.layer.shadowRadius = 5.0;
    background.layer.shadowOpacity = 0.5;
    [self.view addSubview:background];
    
    NSString* welcomeText = @"Who will you play with today?";
    CGSize labelSize = [welcomeText sizeWithFont:[self welcomeTextFont]
                               constrainedToSize:CGSizeMake(1024, CGFLOAT_MAX)];
    CGRect welcomeLabelRect;
    welcomeLabelRect = CGRectMake(1024.0/2.0 - labelSize.width/2.0, 170,
                                  labelSize.width, labelSize.height);
    UILabel* welcomeLabel = [[UILabel alloc] initWithFrame:welcomeLabelRect];
    welcomeLabel.text = welcomeText;
    welcomeLabel.font = [self welcomeTextFont];
    welcomeLabel.textColor = [UIColor colorFromHex:@"#000000" alpha:0.8f];
    welcomeLabel.backgroundColor = [UIColor clearColor];
    welcomeLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [background addSubview:welcomeLabel];
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 200, 1024, 548)];
    [self.view addSubview:self.scrollView];

    // Get the ChatViewController
    PTAppDelegate* appDelegate = (PTAppDelegate*)[[UIApplication sharedApplication] delegate];
    self.chatController = appDelegate.chatController;
    //[self.chatController connectToPlaceholderOpenTokSession];
    [self.chatController configureForDialpad];

    // Add all playmates to the dialpad
    [self drawPlaymates];
    
    // Setup dialing ringer
    [self setupRinger];
    
    // Sign-up button
    if ([[PTUser currentUser] isLoggedIn] == NO) {
        signUpBubbleContainer = [[UIView alloc] initWithFrame:CGRectMake(700.0f, 21.0f, 240.0f, 117.0)];
        signUpBubbleContainer.alpha = 0.0f;
        UIImageView *signUpBubble = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sign-up-join-bubble.png"]];
        signUpBubble.frame = signUpBubbleContainer.bounds;
        UIButton *signUpButton = [UIButton buttonWithType:UIButtonTypeCustom];
        signUpButton.frame = CGRectMake(83.0f, 66.0f, 86.0f, 25.0f);
        [signUpButton setBackgroundImage:[UIImage imageNamed:@"sign-up-blank.png"] forState:UIControlStateNormal];
        [signUpButton setBackgroundImage:[UIImage imageNamed:@"sign-up-press-blank.png"] forState:UIControlStateHighlighted];
        [signUpButton setTitle:@"Sign Up" forState:UIControlStateNormal];
        signUpButton.titleLabel.font = [UIFont boldSystemFontOfSize:10.0f];
        [signUpButton setTitleShadowColor:[UIColor colorFromHex:@"#000000" alpha:0.4f] forState:UIControlStateNormal];
        signUpButton.titleLabel.shadowOffset = CGSizeMake(0.0f, -1.0f);
        [signUpButton addTarget:self action:@selector(signUpDidPress:) forControlEvents:UIControlEventTouchUpInside];
        [signUpBubbleContainer addSubview:signUpBubble];
        [signUpBubbleContainer addSubview:signUpButton];
        [self.view addSubview:signUpBubbleContainer];
    }
    
    // "Invite Buddies" tooltip
    if ([appDelegate shouldShowInviteBuddiesTooltip] == YES) {
        PTPlaymateAddView *playmateAddView = (PTPlaymateAddView *)[self.playmateViews objectForKey:[NSNumber numberWithInteger:-2]];
        ttInviteBuddies = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tooltip-invite-buddies"]];
        ttInviteBuddies.frame = CGRectMake(playmateAddView.frame.origin.x + 185.0f, playmateAddView.frame.origin.y + 50.0f, 244.0f, 76.0);
        ttInviteBuddies.alpha = 0.0f;
        [self.scrollView insertSubview:ttInviteBuddies aboveSubview:playmateAddView];
    }

    // Postcard notification button
    UIImage *normalImage = [UIImage imageNamed:@"photobooth.png"];
    UIImage *pressImage = [UIImage imageNamed:@"photobooth-press.png"];
    postcardButton = [[PTBadgeButton alloc] initWithFrame:CGRectMake(15.0f, 15.0f, normalImage.size.width, normalImage.size.height)];
    [postcardButton setBackgroundImage:normalImage forState:UIControlStateNormal];
    [postcardButton setBackgroundImage:pressImage forState:UIControlStateHighlighted];
    [postcardButton addTarget:self action:@selector(postcardButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:postcardButton];
    
    // Postcards view
    postcardsView = [[PTShowPostcardsView alloc] initWithFrame:background.frame];
    [self.view insertSubview:postcardsView belowSubview:background];
    
    // Settings button
    UIImage *settingsImage = [UIImage imageNamed:@"Settings.png"];
    UIImage *settingsPressImage = [UIImage imageNamed:@"settings-press.png"];
    settingsButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width - settingsImage.size.width - 15, 15.0f, settingsImage.size.width, settingsImage.size.height)];
    [settingsButton setBackgroundImage:settingsImage forState:UIControlStateNormal];
    [settingsButton setBackgroundImage:settingsPressImage forState:UIControlStateHighlighted];
    [settingsButton addTarget:self action:@selector(settingsButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    settingsButton.hidden = YES;
    [self.view addSubview:settingsButton];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Add the spinner to the background view
    float width = background.frame.size.width;
    float height = background.frame.size.height;
    float size = 75.0f;
    PTSpinnerView *spinner = [[PTSpinnerView alloc] initWithFrame:CGRectMake((width - size) / 2, height - (size * 1.333f), size, size)];
    [spinner startSpinning];
    [background addSubview:spinner];
    
    playdateStarting = NO;
    
    if ([[PTUser currentUser] isLoggedIn]) {
        [[PTPlayTellPusher sharedPusher] subscribeToRendezvousChannel];
        settingsButton.hidden = NO;
    } else {
        settingsButton.hidden = YES;
    }
    
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(pusherDidReceiveFriendshipRequestNotification:)
                                                 name:PTPlayTellPusherDidReceiveFriendshipRequestEvent
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(pusherDidReceiveFriendshipAcceptNotification:)
                                                 name:PTPlayTellPusherDidReceiveFriendshipAcceptEvent
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(pusherDidReceiveFriendshipDeclineNotification:)
                                                 name:PTPlayTellPusherDidReceiveFriendshipDeclineEvent
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(checkForPendingPlaydateOnForegrounding:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshPostcardButtonBadgeNumber)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshPlaymates)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(internetConnectionLost)
                                                 name:PTReachabilityInactiveNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(internetConnectionFound)
                                                 name:PTReachabilityActiveNotification
                                               object:nil];
    
    // Check reachability now
    PTAppDelegate *appDelegate = (PTAppDelegate *)[[UIApplication sharedApplication] delegate];
    if (!appDelegate.internetActive) {
        [self internetConnectionLost];
    }

    
    if (self.selectedPlaymateView) {
        [self deactivatePlaymateView];
    }
    
    // Check now for any pending playdates, and register to be notified
    // when we come back to life if any were received while sleeping
    if (playdateRequestedViaPush != YES) {
        // Only check for pending playdates if one didn't come via push notification
        // Otherwise there's playdate collision!
        // More than likely, this will return the same playdate
        // BUT loading playdate id passed via push to be safe
        [self checkForPendingPlaydatesAndNotifyUser]; // TODOGIANCARLO fix this
    } else {
        [self loadPlaydateDataFromPushNotification];
    }
    
    [self.chatController setLeftViewAsPlaceholder];
    [self.chatController setCurrentUserPhoto];
    
    // Have it reload the userphoto if it has not been loaded
    if (![[PTUser currentUser] userPhoto]) {
        // Fetch the current users's photo
        NSURLRequest* urlRequest = [NSURLRequest requestWithURL:[PTUser currentUser].photoURL];
        AFImageRequestOperation* reqeust;
        reqeust = [AFImageRequestOperation imageRequestOperationWithRequest:urlRequest
                                                                    success:^(UIImage *image)
                   {
                       [[PTUser currentUser] setUserPhoto:image];
                       [self.chatController setCurrentUserPhoto];
                   }];
        [reqeust start];
    }
    
    // Remove borders from chat hud
    [self.chatController hideAllBorders];
    [self.chatController restrictToSmallSize:YES];
    
    if (signUpBubbleContainer != nil) {
        [self.view insertSubview:self.chatController.view belowSubview:signUpBubbleContainer];
    } else {
        [self.view addSubview:self.chatController.view];
    }
    
    // This is for when the user has been in a playdate as they don't get notified
    [self refreshPlaymates];
    
    // Check for new postcards and update the badge number on the postcards button
    postcardButton.badgeNumber = 0;
    [self refreshPostcardButtonBadgeNumber];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self deactivatePlaymateView];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidEnterBackgroundNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:PTReachabilityInactiveNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:PTReachabilityActiveNotification
                                                  object:nil];
    
    self.playdateToIgnore = nil;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    // Fade-in all playmate views
    [UIView animateWithDuration:0.7f
                     animations:^{
                         // Playmate views
                         for (id key in [self.playmateViews allKeys]) {
                             PTPlaymateView *playmateView = [self.playmateViews objectForKey:key];
                             playmateView.alpha = 1.0f;
                         }
                     }];
    
    // Fly-in + fade-in sign-up bubble if user not logged in
    if (signUpBubbleContainer != nil) {
        signUpBubbleContainer.frame = CGRectOffset(signUpBubbleContainer.frame, 500.0f, 0.0f);
        [UIView animateWithDuration:0.7f
                         animations:^{
                             signUpBubbleContainer.frame = CGRectOffset(signUpBubbleContainer.frame, -500.0f, 0.0f);
                             signUpBubbleContainer.alpha = 1.0f;
                         }];
    }
    
    // Fly-in + fade-in "invite buddies" tooltip if it exists
    if (ttInviteBuddies != nil) {
        ttInviteBuddies.frame = CGRectOffset(ttInviteBuddies.frame, 500.0f, 0.0f);
        [UIView animateWithDuration:0.7f
                         animations:^{
                             ttInviteBuddies.frame = CGRectOffset(ttInviteBuddies.frame, -500.0f, 0.0f);
                             ttInviteBuddies.alpha = 1.0f;
                         }
                         completion:^(BOOL finished) {
                             [self performSelector:@selector(hideInviteBuddiesTooltip) withObject:nil afterDelay:3.0f];
                         }];
    }
    
    // Remove the spinner
    for (UIView *sub in background.subviews) {
        if ([sub isKindOfClass:[PTSpinnerView class]]) {
            [UIView animateWithDuration:0.7f animations:^{
                sub.alpha = 0.0f;
            } completion:^(BOOL finished) {
                [sub removeFromSuperview];
            }];
        }
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];

    // Hide all playmate views
    for (id key in [self.playmateViews allKeys]) {
        PTPlaymateView *playmateView = [self.playmateViews objectForKey:key];
        playmateView.alpha = 0.0f;
    }
    
    // Hide sign-up bubble
    signUpBubbleContainer.alpha = 0.0f;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupRinger];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)drawPlaymates {
    // Define grid vars
    const NSInteger totalPlaymates = [self.playmates count] + 1; // Extra one for PlaymateAddView (friend import flow)
    const UIEdgeInsets gridMargin = UIEdgeInsetsMake(30.0f, 70.0f, 0.0f, 70.0f);
    const CGSize itemSize = CGSizeMake(200, 150);
    const NSInteger itemsPerRow = 4;
    const CGFloat gridSpace = (self.view.bounds.size.width - gridMargin.left - gridMargin.right - ((CGFloat)itemsPerRow)*itemSize.width)/(CGFloat)(itemsPerRow - 1);
    const NSInteger totalRows = totalPlaymates/itemsPerRow + MIN(totalPlaymates%itemsPerRow, 1);
    
    // Set scroll view content size
    self.scrollView.contentSize = CGSizeMake(self.view.bounds.size.width, gridMargin.top + ((CGFloat)totalRows)*(gridSpace + itemSize.height));
    
    // Draw all items
    self.playmateViews = [NSMutableDictionary dictionary];
    for (int row=0; row<totalRows; row++) {
        for (int cell=0; cell<itemsPerRow; cell++) {
            NSUInteger playmateIndex = (row*itemsPerRow) + cell;

            // Build item frame
            CGPoint itemOrigin = CGPointMake(gridMargin.left + ((CGFloat)cell)*(itemSize.width + gridSpace), gridMargin.top + ((CGFloat)row)*(itemSize.height + gridSpace));
            CGRect itemFrame = CGRectMake(itemOrigin.x, itemOrigin.y, itemSize.width, itemSize.height);
            
            // Are we at the last object in the grid?
            if (playmateIndex == (totalPlaymates - 1)) {
                // Add "Import Friends" playmate view
                PTPlaymateAddView *playmateAddView = [[PTPlaymateAddView alloc] initWithFrame:itemFrame];
                [playmateAddView hideAnimated:NO];
                playmateAddView.delegate = self;
                [self.scrollView addSubview:playmateAddView];
                
                // Save playmate view to hash for easy retrieval
                [self.playmateViews setObject:playmateAddView forKey:[NSNumber numberWithInteger:-2]];
                break;
            }
            
            // Add a playmate view
            PTPlaymate* playmate = [self.playmates objectAtIndex:playmateIndex];
            PTPlaymateView *playmateView = [[PTPlaymateView alloc] initWithFrame:itemFrame playmate:playmate];
            [playmateView hideAnimated:NO];
            playmateView.delegate = self;
            [self.scrollView addSubview:playmateView];
            
            // Save playmate view to hash for easy retrieval
            [self.playmateViews setObject:playmateView forKey:[NSNumber numberWithInteger:playmate.userID]];
        }
    }
}

- (void)refreshPlaymates {
    // Add the spinner to the background view
    float width = background.frame.size.width;
    float height = background.frame.size.height;
    float size = 75.0f;
    PTSpinnerView *spinner = [[PTSpinnerView alloc] initWithFrame:CGRectMake((width - size) / 2, height - (size * 1.333f), size, size)];
    [spinner startSpinning];
    [background addSubview:spinner];
    
    // Loop through the playmates and show the views as in playdate or not
    PTConcretePlaymateFactory* playmateFactory = [PTConcretePlaymateFactory sharedFactory];
    [playmateFactory refreshPlaymatesForUserID:[PTUser currentUser].userID
                                         token:[PTUser currentUser].authToken
                                       success:^
     {
         BOOL shouldRefreshPlaymateViews = NO;
         NSArray *refresh = [[PTConcretePlaymateFactory sharedFactory] allPlaymates];
         for (PTPlaymate *pm in refresh) {
             PTPlaymateView *pmView = [playmateViews objectForKey:[NSNumber numberWithInteger:pm.userID]];
             if (pmView) {
                 [pmView reloadProfilePhoto:pm.photoURL];
                 
                 if ([pm.userStatus isEqualToString:@"playdate"]) {
                     [pmView showUserInPlaydateAnimated:NO];
                 } else {
                     [pmView hideUserInPlaydateAnimated:NO];
                 }
                 
                 if ([pm.friendshipStatus isEqualToString:@"confirmed"]) {
                     [pmView hideFriendshipAwaitingAnimated:YES];
                 }
             } else {
                 // Refresh local playmates array
                 self.playmates = [[PTConcretePlaymateFactory sharedFactory] allPlaymates];
                 
                 // Playmate is new! Perhaps we added a new friend while in contact import flow
                 shouldRefreshPlaymateViews = YES;
             }
         }
         
         // Check if we need to refresh playmate views (if we have new ones)
         if (shouldRefreshPlaymateViews) {
             [self addNewPlaymate];
         }
         
         // Remove the spinner
         [spinner removeFromSuperview];
     } failure:^(NSError *error) {
         LogError(@"%@ error: %@", NSStringFromSelector(_cmd), error);
         
         // Remove the spinner
         [spinner removeFromSuperview];
     }];
}

- (void)addNewPlaymate {
    // Define grid vars
    const NSInteger totalPlaymates = [self.playmates count] + 1; // Extra one for PlaymateAddView (friend import flow)
    const UIEdgeInsets gridMargin = UIEdgeInsetsMake(30.0f, 70.0f, 0.0f, 70.0f);
    const CGSize itemSize = CGSizeMake(200, 150);
    const NSInteger itemsPerRow = 4;
    const CGFloat gridSpace = (self.view.bounds.size.width - gridMargin.left - gridMargin.right - ((CGFloat)itemsPerRow)*itemSize.width)/(CGFloat)(itemsPerRow - 1);
    const NSInteger totalRows = totalPlaymates/itemsPerRow + MIN(totalPlaymates%itemsPerRow, 1);
    
    // Set scroll view content size
    self.scrollView.contentSize = CGSizeMake(self.view.bounds.size.width, gridMargin.top + ((CGFloat)totalRows)*(gridSpace + itemSize.height));
    
    // Find new locations for all playmate views
    NSMutableDictionary *playmateViewLocations = [NSMutableDictionary dictionary];
    NSMutableArray *addedPlaymateViews = [NSMutableArray array];
    for (int row=0; row<totalRows; row++) {
        for (int cell=0; cell<itemsPerRow; cell++) {
            NSUInteger playmateIndex = (row*itemsPerRow) + cell;

            // Build item frame
            CGPoint itemOrigin = CGPointMake(gridMargin.left + ((CGFloat)cell)*(itemSize.width + gridSpace), gridMargin.top + ((CGFloat)row)*(itemSize.height + gridSpace));
            CGRect itemFrame = CGRectMake(itemOrigin.x, itemOrigin.y, itemSize.width, itemSize.height);

            // Are we at the last object in the grid?
            if (playmateIndex == (totalPlaymates - 1)) {
                // Retrieve "Import Friends" playmate view
                PTPlaymateView *playmateAddView = [self.playmateViews objectForKey:[NSNumber numberWithInteger:-2]];
                if (playmateAddView != nil) {
                    // If view exists, save its new frame to a hash we'll reuse later for animations
                    [playmateViewLocations setObject:playmateAddView
                                              forKey:[NSValue valueWithCGRect:itemFrame]];
                }
                break;
            }
            
            // Check if playmate view exists
            PTPlaymate* playmate = [self.playmates objectAtIndex:playmateIndex];
            PTPlaymateView *playmateView = [self.playmateViews objectForKey:[NSNumber numberWithInteger:playmate.userID]];
            if (playmateView != nil) {
                // If view exists, save its new frame to a hash we'll reuse later for animations
                [playmateViewLocations setObject:playmateView
                                          forKey:[NSValue valueWithCGRect:itemFrame]];
            } else {
                // If view doesn't exist, it's the one that was just added (via friend request)
                playmateView = [[PTPlaymateView alloc] initWithFrame:itemFrame playmate:playmate];
                [playmateView hideAnimated:NO];
                playmateView.delegate = self;
                [self.scrollView addSubview:playmateView];
                
                // Save playmate view to hash for easy retrieval
                [self.playmateViews setObject:playmateView forKey:[NSNumber numberWithInteger:playmate.userID]];
                [addedPlaymateViews addObject:playmateView];
            }
        }
    }
    
    // Animate each playmate view to its new location
    [UIView animateWithDuration:0.5f
                     animations:^{
                         for (NSValue *playmateFrameObj in playmateViewLocations) {
                             PTPlaymateView *playmateView = [playmateViewLocations objectForKey:playmateFrameObj];
                             playmateView.frame = [playmateFrameObj CGRectValue];
                         }
                     }
                     completion:^(BOOL finished) {
                         for (PTPlaymateView *addedPlaymateView in addedPlaymateViews) {
                             [addedPlaymateView showAnimated:YES];
                         }
                     }];
}

- (void)refreshPlaymateViews {
    // Define grid vars
    const NSInteger totalPlaymates = [self.playmates count] + 1; // Extra one for PlaymateAddView (friend import flow)
    const UIEdgeInsets gridMargin = UIEdgeInsetsMake(30.0f, 70.0f, 0.0f, 70.0f);
    const CGSize itemSize = CGSizeMake(200, 150);
    const NSInteger itemsPerRow = 4;
    const CGFloat gridSpace = (self.view.bounds.size.width - gridMargin.left - gridMargin.right - ((CGFloat)itemsPerRow)*itemSize.width)/(CGFloat)(itemsPerRow - 1);
    const NSInteger totalRows = totalPlaymates/itemsPerRow + MIN(totalPlaymates%itemsPerRow, 1);
    
    // Set scroll view content size
    self.scrollView.contentSize = CGSizeMake(self.view.bounds.size.width, gridMargin.top + ((CGFloat)totalRows)*(gridSpace + itemSize.height));
    
    // Find new locations for all playmate views
    NSMutableDictionary *playmateViewLocations = [NSMutableDictionary dictionary];
    for (int row=0; row<totalRows; row++) {
        for (int cell=0; cell<itemsPerRow; cell++) {
            NSUInteger playmateIndex = (row*itemsPerRow) + cell;

            // Build item frame
            CGPoint itemOrigin = CGPointMake(gridMargin.left + ((CGFloat)cell)*(itemSize.width + gridSpace), gridMargin.top + ((CGFloat)row)*(itemSize.height + gridSpace));
            CGRect itemFrame = CGRectMake(itemOrigin.x, itemOrigin.y, itemSize.width, itemSize.height);
            
            // Are we at the last object in the grid?
            if (playmateIndex == (totalPlaymates - 1)) {
                // Retrieve "Import Friends" playmate view
                PTPlaymateView *playmateAddView = [self.playmateViews objectForKey:[NSNumber numberWithInteger:-2]];
                if (playmateAddView != nil) {
                    // If view exists, save its new frame to a hash we'll reuse later for animations
                    [playmateViewLocations setObject:playmateAddView
                                              forKey:[NSValue valueWithCGRect:itemFrame]];
                }
                break;
            }
            
            // Check if playmate view exists
            PTPlaymate* playmate = [self.playmates objectAtIndex:playmateIndex];
            PTPlaymateView *playmateView = [self.playmateViews objectForKey:[NSNumber numberWithInteger:playmate.userID]];
            if (playmateView != nil) {
                // Save new frame to a hash we'll use later for animations
                [playmateViewLocations setObject:playmateView
                                          forKey:[NSValue valueWithCGRect:itemFrame]];
            }
        }
    }
    
    // Animate each playmate view to its new location
    [UIView animateWithDuration:0.5f
                     animations:^{
                         for (NSValue *playmateFrameObj in playmateViewLocations) {
                             PTPlaymateView *playmateView = [playmateViewLocations objectForKey:playmateFrameObj];
                             playmateView.frame = [playmateFrameObj CGRectValue];
                         }
                     }];
}

- (void)loadPlaydateDataFromPushNotification {
    // Create the loading view
    loadingView = [[UIView alloc] initWithFrame:self.view.bounds];
    UIImageView* loadingBG = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"date_bg.png"]];
    [loadingView addSubview:loadingBG];

    // Request playdate details from server (using playdate id passed in via push notification)
    PTPlaydateDetailsRequest *playdateDetailsRequest = [[PTPlaydateDetailsRequest alloc] init];
    [playdateDetailsRequest playdateDetailsForPlaydateId:playdateRequestedViaPushId
                                               authToken:[[PTUser currentUser] authToken]
                                         playmateFactory:[PTConcretePlaymateFactory sharedFactory]
                                                 success:^(PTPlaydate *playdate) {
                                                     LogDebug(@"%@ received playdate on push: %@", NSStringFromSelector(_cmd), playdate);
                                                     self.requestedPlaydate = playdate;
                                                     dispatch_async(dispatch_get_main_queue(), ^() {
                                                         [self joinPlaydateWithDelay:6.0f];
                                                     });
                                                 }
                                                 failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                     // Request failed. Assuming there is no existing playdate.
                                                     // Remove the loading view.
                                                     [loadingView removeFromSuperview];
                                                 }];
    
    // Add a loading view to hide dialpad controls
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
         if (playdate.playdateID != playdateToIgnore.playdateID) {
             self.requestedPlaydate = playdate;
             dispatch_async(dispatch_get_main_queue(), ^{
                 [self notifyUserOfRequestedPlaydate];
             });
         }
     } failure:nil];
}

- (void)checkForPendingPlaydateOnForegrounding:(NSNotification*)note {
    if (playdateRequestedViaPush != YES) {
        [self checkForPendingPlaydatesAndNotifyUser]; // TODOGIANCARLO fix this
    }
}

- (void)initiatePlaydateRequestWithPlaymate:(PTPlaymate *)playmate
                                       view:(PTPlaymateView *)playmateView {
    LOGMETHOD;
    // Initiate playdate request
    // TODO This check needs to go away at some point...
    
    UIImage *playmateImage = [playmate userPhoto];
    UIImageView *playmateImageView = [[UIImageView alloc] initWithImage:playmateImage];
    CGRect buttonRect = CGRectZero;
    buttonRect.origin = [self.view convertPoint:playmateView.frame.origin
                                       fromView:self.scrollView];
    buttonRect.size = CGSizeMake(200.0f, 150.0f);//playmateImageView.frame.size;
    playmateImageView.frame = buttonRect;
    playmateImageView.layer.cornerRadius = 12.0;
    playmateImageView.clipsToBounds = YES;
    [self.view insertSubview:playmateImageView aboveSubview:self.chatController.view];
    
    [UIView animateWithDuration:0.4f animations:^{
        CGRect imageViewFrame = playmateImageView.frame;
        imageViewFrame.origin = CGPointMake(308.0f, 0.0f);
        playmateImageView.frame = imageViewFrame;
    } completion:^(BOOL finished) {
        self.chatController.playmate = playmate;
        [playmateImageView removeFromSuperview];
        [self.chatController setLoadingViewForPlaymate:playmate];

        // Dispatching this asynchronously so the UI will update itself before trying to
        // start a playdate
        dispatch_async(dispatch_get_main_queue(), ^{
            // Start the playdate
            [self initiatePlaydateWithPlaymate:playmate];
            
            // If the user is logged in and the
            if ([[PTUser currentUser] isLoggedIn] && ![playmate isARobot]) {
                PTPlaydateCreateRequest *playdateCreateRequest = [[PTPlaydateCreateRequest alloc] init];
                [playdateCreateRequest playdateCreateWithFriend:[NSNumber numberWithUnsignedInt:playmate.userID]
                                                      authToken:[[PTUser currentUser] authToken]
                                                      onSuccess:^(NSDictionary *result)
                 {
                     LogInfo(@"playdateCreateWithFriend response: %@", result);
                     PTPlaydate* aPlaydate = [[PTPlaydate alloc] initWithDictionary:result
                                                                    playmateFactory:[PTConcretePlaymateFactory sharedFactory]];
                     self.chatController.playdate = aPlaydate;
                     [self.chatController connectToOpenTokSession];
                     [self.dateController setPlaydate:aPlaydate];
                     self.dateController = nil;
                     
                     // Send analytics an event for creating a playdate
                     [PTAnalytics sendEventNamed:EventPlaydateCreated withProperties:[NSDictionary dictionaryWithObjectsAndKeys:playmate.username, PropPlaymateId, nil]];
                 } onFailure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                     LogError(@"playdateCreateWithFriend failed: %@", error);
                 }];
                LogInfo(@"Requesting playdate...");
            }
        });
    }];
}

//
// Intended to be called only from playmateClicked:
//
- (void)initiatePlaydateWithPlaymate:(PTPlaymate*)aPlaymate {
    if ([aPlaymate isARobot]) {
        PTSoloUser* robot = (PTSoloUser*)aPlaymate;
        [robot resetScriptState];
        self.dateController = [[PTDateViewController alloc] initWithPlaymate:aPlaymate
                                                          chatViewController:self.chatController];
        robot.dateController = self.dateController;
    } else {
        self.dateController = [[PTDateViewController alloc] initWithPlaymate:aPlaymate
                                                          chatViewController:self.chatController];
    }
    
    if ([[PTPlayTellPusher sharedPusher] isSubscribedToRendezvousChannel]) {
        [[PTPlayTellPusher sharedPusher] unsubscribeFromRendezvousChannel];
    }
    
    PTAppDelegate* appDelegate = (PTAppDelegate*)[[UIApplication sharedApplication] delegate];
    [appDelegate.transitionController transitionToViewController:self.dateController
                                                     withOptions:UIViewAnimationOptionTransitionCrossDissolve];
}

- (void)joinPlaydate {
    [self joinPlaydateWithDelay:0.0f];
}

- (void)joinPlaydateWithDelay:(float)delay {
    LogTrace(@"Joining playdate: %@", self.requestedPlaydate);
    PTPlaymate* otherPlaymate;
    if ([self.requestedPlaydate isUserIDInitiator:[[PTUser currentUser] userID]]) {
        otherPlaymate = [self.requestedPlaydate playmate];
    } else {
        otherPlaymate = [self.requestedPlaydate initiator];
    }
    
    UIImage *playmateImage = [self.selectedPlaymateView.playmate userPhoto];
    UIImageView *playmateImageView = [[UIImageView alloc] initWithImage:playmateImage];
    CGRect buttonRect = CGRectZero;
    buttonRect.origin = self.selectedPlaymateView.frame.origin; //[self.view convertPoint:self.selectedPlaymateView.frame.origin fromView:self.scrollView];
    buttonRect.size = CGSizeMake(200.0f, 150.0f);//playmateImageView.frame.size;
    playmateImageView.frame = buttonRect;
    playmateImageView.layer.cornerRadius = 12.0;
    playmateImageView.clipsToBounds = YES;
    [self.view addSubview:playmateImageView];
    
    // Hide the shim
    self.selectedPlaymateView.layer.zPosition = 0;
    [UIView animateWithDuration:0.4f animations:^{
        shimView.alpha = 0.0f;
        [self.selectedPlaymateView stopShake];
        
        // Move the image to the chat view
        CGRect imageViewFrame = playmateImageView.frame;
        imageViewFrame.origin = CGPointMake(308.0f, 0.0f);
        playmateImageView.frame = imageViewFrame;
    } completion:^(BOOL finished) {
        [playmateImageView removeFromSuperview];
        [self.chatController setLoadingViewForPlaymate:otherPlaymate];
        
        // Dispatching this asynchronously so the UI will update itself before trying to
        // start a playdate
        dispatch_async(dispatch_get_main_queue(), ^{
            // Stop ringing sound
            [self endRinging];
            
            // Unsubscribe from rendezvous channel
            if ([[PTPlayTellPusher sharedPusher] isSubscribedToRendezvousChannel]) {
                [[PTPlayTellPusher sharedPusher] unsubscribeFromRendezvousChannel];
            }
            
            self.chatController.playdate = self.requestedPlaydate;
            [self.chatController setLoadingViewForPlaymate:otherPlaymate];
            if (delay > 0) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC), dispatch_get_current_queue(), ^{
                    [self.chatController connectToOpenTokSession];
                });
            } else {
                [self.chatController connectToOpenTokSession];
            }
            
            self.dateController = [[PTDateViewController alloc] initWithNibName:@"PTDateViewController"
                                                                         bundle:nil];
            
            PTAppDelegate* appDelegate = (PTAppDelegate*)[[UIApplication sharedApplication] delegate];
            [appDelegate.transitionController transitionToViewController:self.dateController withOptions:UIViewAnimationOptionTransitionCrossDissolve];
            
            if (self.requestedPlaydate) {
                [self.dateController setPlaydate:self.requestedPlaydate];
                self.requestedPlaydate = nil;
            }
            
            // Send analytics event for joining a playdate
            [PTAnalytics sendEventNamed:EventPlaydateJoined withProperties:[NSDictionary dictionaryWithObjectsAndKeys:otherPlaymate.username, PropPlaymateId, nil]];
            
            shimView.hidden = YES;
        });
    }];
}

- (void)refreshPostcardButtonBadgeNumber {
    PTNumNewPostcardsRequest* request = [[PTNumNewPostcardsRequest alloc] init];
    [request numNewPostcardsWithUserID:[PTUser currentUser].userID
                               success:^(NSDictionary *result)
     {
         NSInteger numNew = [[result valueForKey:@"num_new_photos"] integerValue];
         postcardButton.badgeNumber = numNew;
     } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
         LogError(@"%@ - error: %@", NSStringFromSelector(_cmd), error);
     }];
}

- (void)postcardButtonPressed {
    // Get the view sizes for transitioning the postcard view
    float height = self.view.frame.size.height;
    float width = self.view.frame.size.width;
    
    if (postcardsShown) {
        // Move the dialpad views back into place
        [UIView animateWithDuration:1.0f animations:^{
            background.frame = CGRectMake(0.0f, 0.0f, width, height);
            self.scrollView.frame = CGRectOffset(self.scrollView.frame, 0.0f, -height);
            self.chatController.view.alpha = 1.0f;
            signUpBubbleContainer.alpha = 1.0f;
        } completion:^(BOOL finished) {
            if ([PTUser currentUser].isLoggedIn) {
                settingsButton.hidden = NO;
            }
        }];
        
        // Set the button images
        [postcardButton setBackgroundImage:[UIImage imageNamed:@"photobooth.png"] forState:UIControlStateNormal];
        [postcardButton setBackgroundImage:[UIImage imageNamed:@"photobooth-press.png"] forState:UIControlStateHighlighted];
        postcardButton.badgeNumber = 0;
        [self refreshPostcardButtonBadgeNumber];
    } else {
        PTAllPostcardsRequest *postcardsRequest = [[PTAllPostcardsRequest alloc] init];
        [postcardsRequest allPostcardsWithUserID:[PTUser currentUser].userID
                                         success:^(NSArray *result)
         {
             NSMutableArray *postcards = [[NSMutableArray alloc] init];
             for (NSDictionary *dict in result) {
                 NSDictionary *postcardDict = [dict objectForKey:@"postcard"];
                 [postcards addObject:[[PTPostcard alloc] initWithDictionary:postcardDict]];
             }
             postcardsView.postcards = postcards;
         } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
             postcardsView.postcards = [NSArray array];
             LogError(@"AllPostcardsRequest failed: %@", error);
         }];
        
        // Move the dialpad views off the screen
        float margin = 50.0f;
        settingsButton.hidden = YES;
        
        [UIView animateWithDuration:1.0f animations:^{
            background.frame = CGRectMake(margin, height, width - (2 * margin), height);
            self.scrollView.frame = CGRectOffset(self.scrollView.frame, 0.0f, height);
            self.chatController.view.alpha = 0.0f;
            signUpBubbleContainer.alpha = 0.0f;
        }];
        
        // Set the button images
        [postcardButton setBackgroundImage:[UIImage imageNamed:@"dialpad.png"] forState:UIControlStateNormal];
        [postcardButton setBackgroundImage:[UIImage imageNamed:@"dialpad-press.png"] forState:UIControlStateHighlighted];
        postcardButton.badgeNumber = 0;
    }
    
    postcardsShown = !postcardsShown;
}

- (void)settingsButtonPressed {
    PTSettingsViewController *settingsViewController = [[PTSettingsViewController alloc] initWithNibName:@"PTSettingsViewController" bundle:nil];
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:settingsViewController];
    
    PTAppDelegate* appDelegate = (PTAppDelegate*)[[UIApplication sharedApplication] delegate];
    [appDelegate.transitionController transitionToViewController:navController withOptions:UIViewAnimationOptionTransitionCrossDissolve];
}

- (void)internetConnectionLost {
    [connectionLossTimer invalidate];
    
    if (connectionLossController == nil) {
        connectionLossController = [[PTConnectionLossViewController alloc] initWithNibName:nil bundle:nil];
    }
    
    if (!showingConnectionLossController) {
        connectionLossTimer = [NSTimer scheduledTimerWithTimeInterval:PTReachabilityDefaultTime target:self selector:@selector(showConnectionLossController:) userInfo:nil repeats:NO];
    }
}

- (void)internetConnectionFound {
    [connectionLossTimer invalidate];
    
    if (connectionLossController == nil) {
        connectionLossController = [[PTConnectionLossViewController alloc] initWithNibName:nil bundle:nil];
    }
    
    if (showingConnectionLossController) {
        connectionLossTimer = [NSTimer scheduledTimerWithTimeInterval:PTReachabilityDefaultTime target:self selector:@selector(hideConnectionLossController:) userInfo:nil repeats:NO];
    }
}

- (void)showConnectionLossController:(NSTimer *)theTimer {
    [connectionLossController startBlinking];
    [self presentModalViewController:connectionLossController animated:YES];
    showingConnectionLossController = YES;
}

- (void)hideConnectionLossController:(NSTimer *)theTimer {
    [connectionLossController stopBlinking];
    [self dismissModalViewControllerAnimated:YES];
    showingConnectionLossController = NO;
    [self refreshPlaymates];
}

#pragma mark - Ringer methods

- (void)setupRinger {
    NSError *playerError;
    NSURL *ringtone = [[NSBundle mainBundle] URLForResource:@"ringtone-connecting" withExtension:@"mp3"];
    AVAudioPlayer *thePlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:ringtone error:&playerError];
    thePlayer.volume = 0.25;
    thePlayer.numberOfLoops = 4;
    self.audioPlayer = thePlayer;
}

- (void)beginRinging {
    [self.audioPlayer play];
}

- (void)endRinging {
    [self.audioPlayer stop];
}

#pragma mark - Pusher notification handlers

- (void)pusherDidReceivePlaydateRequestNotification:(NSNotification*)note {
    PTPlaydate* playdate = [[note userInfo] valueForKey:PTPlaydateKey];
//    NSLog(@"%@ received playdate: %@", NSStringFromSelector(_cmd), playdate);

    // If the pusher event is intended for the current user,
    // notify the user of the event and subscribe to the playdate channel
    // for updates (potentially end playdate)
    if (playdate.playmate.userID == [[PTUser currentUser] userID]) {
        self.requestedPlaydate = playdate;
        [self notifyUserOfRequestedPlaydate];
    } else {
        // Mark players in this playdate as 'pending' in dialpad

        // Find appropriate playmate views
        PTPlaymateView *playmateView1 = [self.playmateViews objectForKey:[NSNumber numberWithInteger:playdate.initiator.userID]];
        PTPlaymate *playmate1 = [[PTConcretePlaymateFactory sharedFactory] playmateWithId:playdate.initiator.userID];
        if (playmateView1 != nil && playmate1 != nil && [playmate1.friendshipStatus isEqualToString:@"confirmed"]) {
            [playmateView1 showUserInPlaydateAnimated:YES];
        }

        PTPlaymateView *playmateView2 = [self.playmateViews objectForKey:[NSNumber numberWithInteger:playdate.playmate.userID]];
        PTPlaymate *playmate2 = [[PTConcretePlaymateFactory sharedFactory] playmateWithId:playdate.playmate.userID];
        if (playmateView2 != nil && playmate2 != nil && [playmate2.friendshipStatus isEqualToString:@"confirmed"]) {
            [playmateView2 showUserInPlaydateAnimated:YES];
        }
    }
}

- (void)pusherDidReceivePlaydateJoinedNotification:(NSNotification*)note {
    PTPlaydate* playdate = [[note userInfo] valueForKey:PTPlaydateKey];
//    NSLog(@"%@ Playdate Joined: %@", NSStringFromSelector(_cmd), playdate);
    
    // Make sure current user didn't paripate in this playdate
    if (playdate.playmate.userID != [[PTUser currentUser] userID] && playdate.initiator.userID != [[PTUser currentUser] userID]) {
        // Mark players in this playdate as 'in playdate' in dialpad
        
        // Find appropriate playmate views
        PTPlaymateView *playmateView1 = [self.playmateViews objectForKey:[NSNumber numberWithInteger:playdate.initiator.userID]];
        PTPlaymate *playmate1 = [[PTConcretePlaymateFactory sharedFactory] playmateWithId:playdate.initiator.userID];
        if (playmateView1 != nil && playmate1 != nil && [playmate1.friendshipStatus isEqualToString:@"confirmed"]) {
            [playmateView1 showUserInPlaydateAnimated:YES];
        }
        
        PTPlaymateView *playmateView2 = [self.playmateViews objectForKey:[NSNumber numberWithInteger:playdate.playmate.userID]];
        PTPlaymate *playmate2 = [[PTConcretePlaymateFactory sharedFactory] playmateWithId:playdate.playmate.userID];
        if (playmateView2 != nil && playmate2 != nil && [playmate2.friendshipStatus isEqualToString:@"confirmed"]) {
            [playmateView2 showUserInPlaydateAnimated:YES];
        }
    }
}

- (void)pusherDidReceivePlaydateEndNotification:(NSNotification*)note {
    PTPlaydate* playdate = [[note userInfo] valueForKey:PTPlaydateKey];
    LogDebug(@"%@ Playdate Ended: %@", NSStringFromSelector(_cmd), playdate);
    
    // Make sure current user didn't participate in this playdate
    if (playdate.playmate.userID != [[PTUser currentUser] userID] && playdate.initiator.userID != [[PTUser currentUser] userID]) {
        // Mark players in this playdate as active in dialpad
        
        // Find appropriate playmate views
        PTPlaymateView *playmateView1 = [self.playmateViews objectForKey:[NSNumber numberWithInteger:playdate.initiator.userID]];
        PTPlaymate *playmate1 = [[PTConcretePlaymateFactory sharedFactory] playmateWithId:playdate.initiator.userID];
        if (playmateView1 != nil && playmate1 != nil && [playmate1.friendshipStatus isEqualToString:@"confirmed"]) {
            [playmateView1 hideUserInPlaydateAnimated:YES];
        }
        
        PTPlaymateView *playmateView2 = [self.playmateViews objectForKey:[NSNumber numberWithInteger:playdate.playmate.userID]];
        PTPlaymate *playmate2 = [[PTConcretePlaymateFactory sharedFactory] playmateWithId:playdate.playmate.userID];
        if (playmateView2 != nil && playmate2 != nil && [playmate2.friendshipStatus isEqualToString:@"confirmed"]) {
            [playmateView2 hideUserInPlaydateAnimated:YES];
        }
    } else {
        // Cancel showing the playdate
        [self deactivatePlaymateView];
        [self endRinging];
    }
}

- (void)pusherDidReceiveFriendshipRequestNotification:(NSNotification*)note {
    PTPlaymate *friend = [note.userInfo objectForKey:@"friend"];
    PTPlaymate *initiator = [note.userInfo objectForKey:@"initiator"];
    
    // We requested someone's friendship
    if (initiator.userID == [[PTUser currentUser] userID]) {
        NSLog(@"We requested (%@)'s friendship", friend.username);
    }

    // Someone requested our friendship
    if (friend.userID == [[PTUser currentUser] userID]) {
        // Add new playmate to the factory
        [[PTConcretePlaymateFactory sharedFactory] addPlaymate:initiator];
        
        // Refresh local playmates array
        self.playmates = [[PTConcretePlaymateFactory sharedFactory] allPlaymates];
        
        // Add new playmate to the dialpad
        [self addNewPlaymate];
    }
}

- (void)pusherDidReceiveFriendshipAcceptNotification:(NSNotification*)note {
    NSNumber *initiator = [note.userInfo objectForKey:@"initiatorID"];
    NSNumber *friend = [note.userInfo objectForKey:@"friendID"];
    
    // We accepted someone's friendship (we're NOT the initiator of the friendship)
    if ([friend integerValue] == [[PTUser currentUser] userID]) {
        // Don't do anything since we handled that when placing the API call
        NSLog(@"We accepted someone's friendship (%i)! (via Pusher)", [initiator integerValue]);
        return;
    }
    
    // Someone accepted our friendship (we're the initiator of the friendship)
    if ([initiator integerValue] == [[PTUser currentUser] userID]) {
        NSLog(@"Someone (%i) accepted our friendship!", [friend integerValue]);
        // Find friend's playmate obj and playmate view
        PTPlaymateView *playmateView = [self.playmateViews objectForKey:friend];
        PTPlaymate *playmate = [[PTConcretePlaymateFactory sharedFactory] playmateWithId:[friend integerValue]];
        if (playmateView != nil && playmate != nil) {
            // Update playmate friendship status
            playmate.friendshipStatus = @"confirmed";
            // Update playmate view to reflect change
            [playmateView hideFriendshipAwaitingAnimated:YES];
        } else {
            [self refreshPlaymates];
        }
    }
}

- (void)pusherDidReceiveFriendshipDeclineNotification:(NSNotification*)note {
    NSNumber *initiator = [note.userInfo objectForKey:@"initiatorID"];
    NSNumber *friend = [note.userInfo objectForKey:@"friendID"];
    
    // We declined someone's friendship (we're NOT the initiator of the friendship)
    if ([friend integerValue] == [[PTUser currentUser] userID]) {
        // Don't do anything since we handled that when placing the API call
        NSLog(@"We declined someone's friendship (%i)! (via Pusher)", [initiator integerValue]);
        return;
    }
    
    // Someone declined our friendship (we're the initiator of the friendship)
    if ([initiator integerValue] == [[PTUser currentUser] userID]) {
        NSLog(@"Someone (%i) declined our friendship!", [friend integerValue]);
        // Find friend's playmate obj and playmate view
        PTPlaymateView *playmateView = [self.playmateViews objectForKey:friend];
        PTPlaymate *playmate = [[PTConcretePlaymateFactory sharedFactory] playmateWithId:[friend integerValue]];
        if (playmateView != nil && playmate != nil) {
            // Delete this playmate obj from factory
            [[PTConcretePlaymateFactory sharedFactory] removePlaymateUsingId:playmate.userID];
            
            // Delete playmate view and move all others to reflect this change
            [UIView animateWithDuration:0.3f
                             animations:^{
                                 playmateView.alpha = 0.0f;
                             } completion:^(BOOL finished) {
                                 [self refreshPlaymateViews];
                             }];
        }
    }
}

- (void)notifyUserOfRequestedPlaydate {
    // Find the playmate view
    PTPlaymateView *playmateView = [self.playmateViews objectForKey:[NSNumber numberWithInteger:self.requestedPlaydate.initiator.userID]];
    if (!playmateView) {
        return;
    }
    
    // Start shaking playmate view + show shim
    [self activatePlaymateView:playmateView];
    
    // Start playing ringing sound
    [self beginRinging];

    // Unsubscribe from rendezvous channel
    //[[PTPlayTellPusher sharedPusher] unsubscribeFromRendezvousChannel];
    
    // Starting listening to end playdate event
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playmateEndedPlaydate:)
                                                 name:@"PlayDateEndPlaydate"
                                               object:nil];
}

- (void)activatePlaymateView:(PTPlaymateView *)playmateView {
    // Init the shim (if needed)
    if (shimView == nil) {
        shimView = [[UIView alloc] initWithFrame:self.view.bounds];
        shimView.backgroundColor = [UIColor blackColor];
        shimView.layer.zPosition = 100;
        shimView.hidden = YES;
        [self.view addSubview:shimView];

        // Add shim tap recognizer
        UITapGestureRecognizer *shimTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(ignorePlaydateRequest:)];
        [shimView addGestureRecognizer:shimTapRecognizer];
    }
    
    // Put the playmate view above the shim
    CGRect newFrame = [self.view convertRect:playmateView.frame fromView:playmateView.superview];
    playmateView.frame = newFrame;
    [self.view addSubview:playmateView];
    
    // Show the shim
    playmateView.layer.zPosition = 500;
    shimView.alpha = 0.0f;
    shimView.hidden = NO;
    [UIView animateWithDuration:0.5f animations:^{
        shimView.alpha = 0.7f;
    }];

    // Store view for future access
    self.selectedPlaymateView = playmateView;
    
    // Shake the playmate view
    [playmateView beginShake];
}

- (void)deactivatePlaymateView {
    if (self.selectedPlaymateView == nil) {
        return;
    }
    
    // Stop shaking playmate view
    [self.selectedPlaymateView stopShake];
    
    // Hide the shim
    self.selectedPlaymateView.layer.zPosition = 0;
    [UIView animateWithDuration:0.5f animations:^{
        shimView.alpha = 0.0f;
    } completion:^(BOOL finished) {
        shimView.hidden = YES;
        
        // Put back in the dialpad scroll view (behind shim)
        CGRect newFrame = [self.scrollView convertRect:self.selectedPlaymateView.frame fromView:self.view];
        self.selectedPlaymateView.frame = newFrame;
        [self.scrollView addSubview:self.selectedPlaymateView];
        
        // Clear out reference
        self.selectedPlaymateView = nil;
    }];
}

- (void)playmateEndedPlaydate:(NSNotification*)note {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"PlayDateEndPlaydate"
                                                  object:nil];
    [[PTPlayTellPusher sharedPusher] unsubscribeFromPlaydateChannel:self.requestedPlaydate.pusherChannelName];
    [[PTPlayTellPusher sharedPusher] subscribeToRendezvousChannel];
    
    // Stop playmate view shaking + hide shim
    [self deactivatePlaymateView];
    
    // Stop ringing sound
    [self endRinging];
}

- (UIFont*)welcomeTextFont {
    return [UIFont fontWithName:@"HelveticaNeue-Light" size:28.0];
}

- (void)ignorePlaydateRequest:(UIGestureRecognizer*)tapRecognizer {
    NSLog(@"ignorePlaydateRequest");
    LOGMETHOD;
    // Stop shaking + hide shim
    [self deactivatePlaymateView];
    
    // Stop ringing sound
    [self endRinging];
    
    // Notify server of playdate denial
    PTPlaydateDisconnectRequest *playdateDisconnectRequest = [[PTPlaydateDisconnectRequest alloc] init];
    [playdateDisconnectRequest playdateDisconnectWithPlaydateId:[NSNumber numberWithInt:self.requestedPlaydate.playdateID]
                                                      authToken:[[PTUser currentUser] authToken]
                                                      onSuccess:nil
                                                      onFailure:nil
     ];
    self.requestedPlaydate = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

#pragma mark - Playmate delegates

- (void)playmateDidTouch:(PTPlaymateView *)playmateView playmate:(PTPlaymate *)playmate {
    // Are we trying to respond to an incoming playdate request?
    if (self.selectedPlaymateView == playmateView) {
        [[PTPlayTellPusher sharedPusher] unsubscribeFromRendezvousChannel];
        [[PTPlayTellPusher sharedPusher] subscribeToPlaydateChannel:self.requestedPlaydate.pusherChannelName];
        [self joinPlaydate];
        return;
    }
    
    if (!playdateStarting) {
        // We are initiating a playdate request
        [self initiatePlaydateRequestWithPlaymate:playmate view:playmateView];
        playdateStarting = YES;
    }
}

- (void)playmateDidAcceptFriendship:(PTPlaymateView *)playmateView playmate:(PTPlaymate *)playmate {
    NSLog(@"API: Friendship accepting with playmate: %i", playmate.userID);
    
    // Spinner view
    float width = playmateView.frame.size.width;
    float height = playmateView.frame.size.height;
    float size = 75.0f;
    PTSpinnerView *spinner = [[PTSpinnerView alloc] initWithFrame:CGRectMake((width - size) / 2, (height - size) / 2, size, size)];
    spinner.alpha = 0.0f;
    [spinner startSpinning];
    [playmateView addSubview:spinner];
    
    // Animate in the spinner
    [UIView animateWithDuration:0.3f animations:^{
        spinner.alpha = 1.0f;
    }];
    
    [playmateView hideFriendshipConfirmationAnimated:YES];
    playmateView.userInteractionEnabled = NO;
    
    PTFriendshipAcceptRequest *friendshipAcceptRequest = [[PTFriendshipAcceptRequest alloc] init];
    [friendshipAcceptRequest acceptFriendshipWith:playmate.userID
                                        authToken:[[PTUser currentUser] authToken]
                                          success:^(NSDictionary *result)
     {
         // Update playmate view to reflect change
         dispatch_async(dispatch_get_main_queue(), ^{
             // Update playmate friendship status
             playmate.friendshipStatus = @"confirmed";
             
             // Hide the spinner
             [UIView animateWithDuration:0.3f animations:^{
                 spinner.alpha = 0.0f;
             } completion:^(BOOL finished) {
                 [spinner removeFromSuperview];
             }];
             
             playmateView.userInteractionEnabled = YES;
         });
     }
                                          failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
     {
         dispatch_async(dispatch_get_main_queue(), ^{
             // Show alert
             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                             message:@"Could not accept friendship at this time. Please try again later."
                                                            delegate:nil
                                                   cancelButtonTitle:@"Ok"
                                                   otherButtonTitles:nil];
             [alert show];
             
             // Enable confirmation buttons again
             [playmateView enableFriendshipConfirmationButtons];
             [playmateView showFriendshipConfirmationAnimated:YES];
             
             // Hide the spinner
             [UIView animateWithDuration:0.3f animations:^{
                 spinner.alpha = 0.0f;
             }];
             
             playmateView.userInteractionEnabled = YES;
         });
     }];
}

- (void)playmateDidDeclineFriendship:(PTPlaymateView *)playmateView playmate:(PTPlaymate *)playmate {
    NSLog(@"API: Friendship declining with playmate: %i", playmate.userID);
    
    // Spinner view
    float width = playmateView.frame.size.width;
    float height = playmateView.frame.size.height;
    float size = 75.0f;
    PTSpinnerView *spinner = [[PTSpinnerView alloc] initWithFrame:CGRectMake((width - size) / 2, (height - size) / 2, size, size)];
    spinner.alpha = 0.0f;
    [spinner startSpinning];
    [playmateView addSubview:spinner];
    
    // Animate in the spinner
    [UIView animateWithDuration:0.3f animations:^{
        spinner.alpha = 1.0f;
    }];
    
    [playmateView hideFriendshipConfirmationAnimated:YES];
    playmateView.userInteractionEnabled = NO;
    
    PTFriendshipDeclineRequest *friendshipDeclineRequest = [[PTFriendshipDeclineRequest alloc] init];
    [friendshipDeclineRequest declineFriendshipFrom:playmate.userID
                                          authToken:[[PTUser currentUser] authToken]
                                            success:^(NSDictionary *result)
     {
         // Update playmate view to reflect change
         dispatch_async(dispatch_get_main_queue(), ^{
             // Delete this playmate obj from factory
             [[PTConcretePlaymateFactory sharedFactory] removePlaymateUsingId:playmate.userID];
             
             // Refresh local playmates array
             self.playmates = [[PTConcretePlaymateFactory sharedFactory] allPlaymates];
             
             // Delete playmate view and move all others to reflect this change
             [UIView animateWithDuration:0.3f
                              animations:^{
                                  playmateView.alpha = 0.0f;
                              } completion:^(BOOL finished) {
                                  [self refreshPlaymateViews];
                              }];
         });
     }
                                            failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
     {
         dispatch_async(dispatch_get_main_queue(), ^{
             // Show alert
             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                             message:@"Could not accept friendship at this time. Please try again later."
                                                            delegate:nil
                                                   cancelButtonTitle:@"Ok"
                                                   otherButtonTitles:nil];
             [alert show];
             
             // Enable confirmation buttons again
             [playmateView enableFriendshipConfirmationButtons];
             [playmateView showFriendshipConfirmationAnimated:YES];
             
             // Hide the spinner
             [UIView animateWithDuration:0.3f animations:^{
                 spinner.alpha = 0.0f;
             }];
             
             playmateView.userInteractionEnabled = YES;
         });
     }];
}

- (void)playmateDidPressAddFriends:(PTPlaymateView *)playmateView {
    // Is the user logged in?
    if ([[PTUser currentUser] isLoggedIn] == YES) {
        ABAddressBookRef addressBook;
        // iOS 6 and up
        if (ABAddressBookGetAuthorizationStatus != NULL) {
            ABAuthorizationStatus status = ABAddressBookGetAuthorizationStatus();
            
            // Check address book permission
            if (status != kABAuthorizationStatusAuthorized) {
                CFErrorRef error = nil;
                addressBook = ABAddressBookCreateWithOptions(NULL, &error);
                ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        //                if (error) {
                        //                    NSError* nsError = (__bridge NSError*)error;
                        //                    NSLog(@"nsError: %@", nsError.localizedDescription);
                        //                }
                        // Permission granted?
                        if (granted && !error) {
                            [self getContactsFromAddressBook:addressBook];
                        } else {
                            // Go to the inviter screen with no contacts
                            PTContactSelectViewController *contactSelectViewController = [[PTContactSelectViewController alloc]
                                                                                          initWithNibName:@"PTContactSelectViewController"
                                                                                          bundle:nil
                                                                                          withContacts:[NSArray array]];
                            contactSelectViewController.sourceType = @"Address Book";
                            
                            UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:contactSelectViewController];
                            
                            PTAppDelegate* appDelegate = (PTAppDelegate*)[[UIApplication sharedApplication] delegate];
                            [appDelegate.transitionController transitionToViewController:navController withOptions:UIViewAnimationOptionTransitionCrossDissolve];
                        }
                    });
                });
            } else {
                addressBook = ABAddressBookCreate();
                [self getContactsFromAddressBook:addressBook];
            }
        } else {
            // Pre-iOS 6
            addressBook = ABAddressBookCreate();
            [self getContactsFromAddressBook:addressBook];
        }
//        PTContactImportViewController *contactImportViewController = [[PTContactImportViewController alloc] initWithNibName:@"PTContactImportViewController" bundle:nil];
//        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:contactImportViewController];
//        
//        PTAppDelegate* appDelegate = (PTAppDelegate*)[[UIApplication sharedApplication] delegate];
//        [appDelegate.transitionController transitionToViewController:navController withOptions:UIViewAnimationOptionTransitionCrossDissolve];
    } else {
        // If user isn't logged in, redirect them to sign-up form
        [self signUpDidPress:nil];
    }
}

- (void)getContactsFromAddressBook:(ABAddressBookRef)addressBook {
    CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
    CFIndex nPeople = ABAddressBookGetPersonCount(addressBook);
    
    NSMutableArray *abContacts = [NSMutableArray array];
    for (int i=0; i<nPeople; i++) {
        ABRecordRef ref = CFArrayGetValueAtIndex(allPeople, i);
        NSString *firstName = (__bridge NSString *)ABRecordCopyValue(ref, kABPersonFirstNameProperty);
        NSString *lastName = (__bridge NSString *)ABRecordCopyValue(ref, kABPersonLastNameProperty);
        NSString *fullName = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
        
        // Get emails
        ABMultiValueRef emailsRef = ABRecordCopyValue(ref, kABPersonEmailProperty);
        if (emailsRef) {
            for (int i=0; i<ABMultiValueGetCount(emailsRef); i++) {
                NSString *email = (__bridge NSString *)ABMultiValueCopyValueAtIndex(emailsRef, i);
                
                // Save the contact
                NSDictionary *contact = [NSDictionary dictionaryWithObjectsAndKeys:
                                         [fullName copy],                @"name",
                                         [[email copy] lowercaseString], @"email",
                                         @"iPad Address Book",           @"source",
                                         nil];
                [abContacts addObject:contact];
            }
        }
        
        // Cleanup
        CFRelease(ref);
    }
    
    NSLog(@"---> Got contacts: %i", [abContacts count]);
    
    // Load select controller
    PTContactSelectViewController *contactSelectViewController = [[PTContactSelectViewController alloc]
                                                                  initWithNibName:@"PTContactSelectViewController"
                                                                  bundle:nil
                                                                  withContacts:abContacts];
    contactSelectViewController.sourceType = @"Address Book";
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:contactSelectViewController];
    
    PTAppDelegate* appDelegate = (PTAppDelegate*)[[UIApplication sharedApplication] delegate];
    [appDelegate.transitionController transitionToViewController:navController withOptions:UIViewAnimationOptionTransitionCrossDissolve];
}

#pragma mark - New user flow methods

- (void)signUpDidPress:(id)sender {
    // Load the create new user nav
    PTAppDelegate* appDelegate = (PTAppDelegate*)[[UIApplication sharedApplication] delegate];
    PTNewUserNavigationController *newUserNavigationController = [[PTNewUserNavigationController alloc] initWithDefaultViewController];
    
    // Transition to it
    [appDelegate.transitionController transitionToViewController:newUserNavigationController
                                                     withOptions:UIViewAnimationOptionTransitionCrossDissolve];
}

#pragma mark - Tooltip helpers

- (void)hideInviteBuddiesTooltip {
    [UIView animateWithDuration:0.4f
                     animations:^{
                         ttInviteBuddies.alpha = 0.0f;
                     }
                     completion:^(BOOL finished) {
                         [ttInviteBuddies removeFromSuperview];
                     }];
}

#pragma mark - Logout flow (not called anywhere right now)

- (void)logoutDidPress:(id)sender {
    // Clear out current user values
    [[PTUser currentUser] resetUser];
    
    // Load new user workflow
    PTNewUserNavigationController *newUserNavigationController = [[PTNewUserNavigationController alloc] initWithDefaultViewController];
    PTAppDelegate* appDelegate = (PTAppDelegate*)[[UIApplication sharedApplication] delegate];
    [appDelegate.transitionController transitionToViewController:newUserNavigationController withOptions:UIViewAnimationOptionTransitionCrossDissolve];
}

@end