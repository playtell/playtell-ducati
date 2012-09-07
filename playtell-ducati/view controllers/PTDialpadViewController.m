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
#import "PTPlaymateView.h"
#import "PTUser.h"
#import "TransitionController.h"
#import "PTPlaydateDetailsRequest.h"
#import "PTUsersGetStatusRequest.h"
#import "UIView+PlayTell.h"
#import "PTFriendshipAcceptRequest.h"
#import "PTFriendshipDeclineRequest.h"
#import "PTContactImportViewController.h"

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
@synthesize audioPlayer;

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
    
    // Add all playmates to the dialpad
    [self drawPlaymates];
    
    // Setup dialing ringer
    [self setupRinger];
}

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
        [self checkForPendingPlaydatesAndNotifyUser];
    } else {
        [self loadPlaydateDataFromPushNotification];
    }
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(checkForPendingPlaydateOnForegrounding:)
//                                                 name:UIApplicationWillEnterForegroundNotification
//                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self deactivatePlaymateView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    // Fade-in all playmate views
    [UIView animateWithDuration:0.7f
                     animations:^{
                         for (id key in [self.playmateViews allKeys]) {
                             PTPlaymateView *playmateView = [self.playmateViews objectForKey:key];
                             playmateView.alpha = 1.0f;
                         }
                     }];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];

    // Hide all playmate views
    for (id key in [self.playmateViews allKeys]) {
        PTPlaymateView *playmateView = [self.playmateViews objectForKey:key];
        playmateView.alpha = 0.0f;
    }
}

- (void)drawPlaymates {
    // Define grid vars
    const NSInteger totalPlaymates = [self.playmates count];
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
            if (playmateIndex >= totalPlaymates) {
                break;
            }
            
            // Build item frame
            CGPoint itemOrigin = CGPointMake(gridMargin.left + ((CGFloat)cell)*(itemSize.width + gridSpace), gridMargin.top + ((CGFloat)row)*(itemSize.height + gridSpace));
            CGRect itemFrame = CGRectMake(itemOrigin.x, itemOrigin.y, itemSize.width, itemSize.height);
            
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
    
    //    // TODO : revist the naming of these variables..
    //    NSUInteger numPlaymates = self.playmates.count + 1;
    //
    //    CGFloat margin = 70;
    //    const CGFloat leftMargin = margin;
    //    const CGFloat rightMargin = margin;
    //    const CGFloat topMargin = 30;
    //    CGFloat rowSpacing = 10;
    //    const NSUInteger itemsPerRow = 4;
    //    const CGSize buttonSize = CGSizeMake(200, 150);
    
    //    CGFloat W = self.view.bounds.size.width;
    //    CGFloat interCellPadding = (W - leftMargin - rightMargin - ((CGFloat)itemsPerRow)*buttonSize.width)/(CGFloat)(itemsPerRow - 1);
    
    // Testing...
    //    rowSpacing = interCellPadding;
    //    NSUInteger numRows = numPlaymates/itemsPerRow + MIN(numPlaymates%itemsPerRow, 1);
    
    //    NSMutableDictionary* playmatesAndButtons = [NSMutableDictionary dictionary];
    //    for (int rowIndex = 0; rowIndex < numRows; rowIndex++) {
    //        for (int cellIndex = 0; cellIndex < itemsPerRow; cellIndex++) {
    //            NSUInteger playmateIndex = (rowIndex*itemsPerRow) + cellIndex;
    //            if (playmateIndex >= numPlaymates) {
    //                continue;
    //            }
    //
    //            CGFloat cellX = leftMargin + ((CGFloat)cellIndex)*(buttonSize.width + interCellPadding);
    //            CGFloat cellY = topMargin + ((CGFloat)rowIndex)*(buttonSize.height + rowSpacing);
    //
    //            UIButton* button;
    //            if (playmateIndex == numPlaymates - 1) {
    //                button = [UIButton buttonWithType:UIButtonTypeCustom];
    //                button.frame = CGRectMake(0, 0, buttonSize.width, buttonSize.height);
    //                [button setImage:[UIImage imageNamed:@"add-family.png"] forState:UIControlStateNormal];
    //                [playmatesAndButtons setObject:button
    //                                        forKey:@"AddUserButton"];
    //                CGRect buttonFrame = button.frame;
    //                buttonFrame.origin = CGPointMake(cellX, cellY);
    //                button.frame = buttonFrame;
    //                [self.scrollView addSubview:button];
    //            } else {
    //                PTPlaymate* currentPlaymate = [self.playmates objectAtIndex:playmateIndex];
    //                PTPlaymateView *currentPlaymateView = [[PTPlaymateView alloc] initWithFrame:CGRectMake(cellX, cellY, buttonSize.width, buttonSize.height) playmate:currentPlaymate];
    ////                button = [PTPlaymateButton playmateButtonWithPlaymate:currentPlaymate];
    ////                [button addTarget:self action:@selector(playmateClicked:) forControlEvents:UIControlEventTouchUpInside];
    ////                [playmatesAndButtons setObject:button
    ////                                        forKey:[self stringFromUInt:currentPlaymate.userID]];
    //                [self.scrollView addSubview:currentPlaymateView];
    //            }
    //        }
    //    }
    //    TODO: Rewrite as self.playmateViews
    //    self.userButtonHash = [NSDictionary dictionaryWithDictionary:playmatesAndButtons];
    
    //    self.scrollView.contentSize = CGSizeMake(W, topMargin + ((CGFloat)(numRows+1))*(rowSpacing + buttonSize.height));
    
    //    // Get a list of all playmate ids and get their current status
    //    NSMutableArray *ids = [[NSMutableArray alloc] init];
    //    for (NSString *key in [self.userButtonHash allKeys]) {
    //        if (![key isEqualToString:@"AddUserButton"]) {
    //            [ids addObject:key];
    //        }
    //    }
    //    PTUsersGetStatusRequest *usersGetStatusRequest = [[PTUsersGetStatusRequest alloc] init];
    //    [usersGetStatusRequest usersGetStatusForUserIds:ids
    //                                          authToken:[[PTUser currentUser] authToken]
    //                                            success:^(NSDictionary *result) {
    //                                                NSArray *statuses = [result objectForKey:@"status"];
    //                                                for (NSDictionary *userStatus in statuses) {
    //                                                    NSInteger user_id = [[userStatus objectForKey:@"id"] integerValue];
    //                                                    NSString *user_status = [userStatus objectForKey:@"status"];
    //                                                    PTPlaymateButton *button = [self.userButtonHash objectForKey:[self stringFromUInt:user_id]];
    //                                                    if (button == nil) {
    //                                                        return;
    //                                                    }
    //                                                    if ([user_status isEqualToString:@"pending"]) {
    //                                                        [button setPending];
    //                                                    } else if ([user_status isEqualToString:@"playdate"]) {
    //                                                        [button setPlaydating];
    //                                                    }
    //                                                }
    //                                            }
    //                                            failure:nil
    //     ];
}

- (void)addNewPlaymate {
    // Define grid vars
    const NSInteger totalPlaymates = [self.playmates count];
    const UIEdgeInsets gridMargin = UIEdgeInsetsMake(30.0f, 70.0f, 0.0f, 70.0f);
    const CGSize itemSize = CGSizeMake(200, 150);
    const NSInteger itemsPerRow = 4;
    const CGFloat gridSpace = (self.view.bounds.size.width - gridMargin.left - gridMargin.right - ((CGFloat)itemsPerRow)*itemSize.width)/(CGFloat)(itemsPerRow - 1);
    const NSInteger totalRows = totalPlaymates/itemsPerRow + MIN(totalPlaymates%itemsPerRow, 1);
    
    // Set scroll view content size
    self.scrollView.contentSize = CGSizeMake(self.view.bounds.size.width, gridMargin.top + ((CGFloat)totalRows)*(gridSpace + itemSize.height));
    
    // Find new locations for all playmate views
    NSMutableDictionary *playmateViewLocations = [NSMutableDictionary dictionary];
    PTPlaymateView *addedPlaymateView;
    for (int row=0; row<totalRows; row++) {
        for (int cell=0; cell<itemsPerRow; cell++) {
            NSUInteger playmateIndex = (row*itemsPerRow) + cell;
            if (playmateIndex >= totalPlaymates) {
                break;
            }
            
            // Build item frame
            CGPoint itemOrigin = CGPointMake(gridMargin.left + ((CGFloat)cell)*(itemSize.width + gridSpace), gridMargin.top + ((CGFloat)row)*(itemSize.height + gridSpace));
            CGRect itemFrame = CGRectMake(itemOrigin.x, itemOrigin.y, itemSize.width, itemSize.height);
            
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
                addedPlaymateView = playmateView;
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
                         if (addedPlaymateView != nil) {
                             [addedPlaymateView showAnimated:YES];
                         }
                     }];
}

- (void)refreshPlaymateViews {
    // Define grid vars
    const NSInteger totalPlaymates = [self.playmates count];
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
            if (playmateIndex >= totalPlaymates) {
                break;
            }
            
            // Build item frame
            CGPoint itemOrigin = CGPointMake(gridMargin.left + ((CGFloat)cell)*(itemSize.width + gridSpace), gridMargin.top + ((CGFloat)row)*(itemSize.height + gridSpace));
            CGRect itemFrame = CGRectMake(itemOrigin.x, itemOrigin.y, itemSize.width, itemSize.height);
            
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

- (void)initiatePlaydateRequestWithPlaymate:(PTPlaymate *)playmate {
    LOGMETHOD;
    // Initiate playdate request
    [self joinPlaydate];

    PTPlaydateCreateRequest *playdateCreateRequest = [[PTPlaydateCreateRequest alloc] init];
    [playdateCreateRequest playdateCreateWithFriend:[NSNumber numberWithUnsignedInt:playmate.userID]
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
    // Hide the shim
    [UIView animateWithDuration:0.5f animations:^{
        shimView.alpha = 0.0f;
    } completion:^(BOOL finished) {
        shimView.hidden = YES;
    }];
    
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
    LogDebug(@"%@ received playdate: %@", NSStringFromSelector(_cmd), playdate);

    // If the pusher event is intended for the current user,
    // notify the user of the event and subscribe to the playdate channel
    // for updates (potentially end playdate)
    if (playdate.playmate.userID == [[PTUser currentUser] userID]) {
        self.requestedPlaydate = playdate;
        [self notifyUserOfRequestedPlaydateAndSubscribeToPlaydateChannel];
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
    LogDebug(@"%@ Playdate Joined: %@", NSStringFromSelector(_cmd), playdate);
    
    // Make sure current user didn't participate in this playdate
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
        
        // Add new playmate to the dialpad
        [self addNewPlaymate];
    }
}

- (void)pusherDidReceiveFriendshipAcceptNotification:(NSNotification*)note {
    NSNumber *initiator = [note.userInfo objectForKey:@"initiatorID"];
    NSNumber *friend = [note.userInfo objectForKey:@"friendID"];
    
    // We accepted someone's friendship (we're NOT the initiator of the friendship)
    if ([friend integerValue] == [[PTUser currentUser] userID]) {
        NSLog(@"We accepted someone's friendship (%i)!", [initiator integerValue]);
        // Find friend's playmate obj and playmate view
        PTPlaymateView *playmateView = [self.playmateViews objectForKey:initiator];
        PTPlaymate *playmate = [[PTConcretePlaymateFactory sharedFactory] playmateWithId:[initiator integerValue]];
        if (playmateView != nil && playmate != nil) {
            // Update playmate friendship status
            playmate.friendshipStatus = @"confirmed";
            // Update playmate view to reflect change
            [playmateView hideFriendshipConfirmationAnimated:YES];
        }
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
        }
    }
}

- (void)pusherDidReceiveFriendshipDeclineNotification:(NSNotification*)note {
    NSNumber *initiator = [note.userInfo objectForKey:@"initiatorID"];
    NSNumber *friend = [note.userInfo objectForKey:@"friendID"];
    
    // We declined someone's friendship (we're NOT the initiator of the friendship)
    if ([friend integerValue] == [[PTUser currentUser] userID]) {
        NSLog(@"We declined someone's friendship (%i)!", [initiator integerValue]);
        // Find friend's playmate obj and playmate view
        PTPlaymateView *playmateView = [self.playmateViews objectForKey:initiator];
        PTPlaymate *playmate = [[PTConcretePlaymateFactory sharedFactory] playmateWithId:[initiator integerValue]];
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

- (void)notifyUserOfRequestedPlaydateAndSubscribeToPlaydateChannel {
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
    [[PTPlayTellPusher sharedPusher] unsubscribeFromRendezvousChannel];
    [[PTPlayTellPusher sharedPusher] subscribeToPlaydateChannel:self.requestedPlaydate.pusherChannelName];
    
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
        [self joinPlaydate];
        return;
    }
    
    // We are initiating a playdate request
    [self initiatePlaydateRequestWithPlaymate:playmate];
}

- (void)playmateDidAcceptFriendship:(PTPlaymateView *)playmateView playmate:(PTPlaymate *)playmate {
    NSLog(@"API: Friendship accepting with playmate: %i", playmate.userID);
    PTFriendshipAcceptRequest *friendshipAcceptRequest = [[PTFriendshipAcceptRequest alloc] init];
    [friendshipAcceptRequest acceptFriendshipWith:playmate.userID
                                        authToken:[[PTUser currentUser] authToken]
                                          success:nil // Don't need since Pusher will notify the client of this and will handle UI changes
                                          failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
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
                                              });
                                          }];
}

- (void)playmateDidDeclineFriendship:(PTPlaymateView *)playmateView playmate:(PTPlaymate *)playmate {
    NSLog(@"API: Friendship declining with playmate: %i", playmate.userID);
    PTFriendshipDeclineRequest *friendshipDeclineRequest = [[PTFriendshipDeclineRequest alloc] init];
    [friendshipDeclineRequest declineFriendshipFrom:playmate.userID
                                          authToken:[[PTUser currentUser] authToken]
                                            success:nil // Don't need since Pusher will notify the client of this and will handle UI changes
                                            failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
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
                                                });
                                            }];
}

@end
