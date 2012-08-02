//
//  TictactoeViewController.m
//  playtell-ducati
//
//  Created by Giancarlo Daniele on 7/28/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import "TictactoeViewController.h"
#import "TictactoeView.h"
#import <QuartzCore/QuartzCore.h>

// TODOGIANCARLO figure out which imports i need
#import "Logging.h"
#import "PTAppDelegate.h"
#import "PTCheckForPlaydateRequest.h"
#import "PTConcretePlaymateFactory.h"
#import "PTDateViewController.h"
#import "PTDialpadViewController.h"
#import "PTBookView.h"
#import "PTChatHUDView.h"
#import "PTPageView.h"
#import "PTUser.h"
#import "PTPageTurnRequest.h"
#import "PTPlayTellPusher.h"
#import "PTBookChangeRequest.h"
#import "PTBookCloseRequest.h"
#import "PTPlaydateDisconnectRequest.h"
#import "PTVideoPhone.h"
#import "PTPlaydateJoinedRequest.h"
#import "TransitionController.h"
#import "PTPlayTellPusher.h"
#import "PTPlaydate+InitatorChecking.h"
#import "PTPlaydateFingerTapRequest.h"
#import "PTPlaydateFingerEndRequest.h"
#import "PTBooksListRequest.h"
#import "TictactoeViewController.h"

@interface TictactoeViewController ()
@property (nonatomic, strong) PTChatHUDView* chatView;
@property (nonatomic, weak) OTSubscriber* playmateSubscriber;
@property (nonatomic, weak) OTPublisher* myPublisher;
@end

@implementation TictactoeViewController

@synthesize chatView, board_id, playdate, playmateSubscriber, myPublisher, endPlaydate, endPlaydateForreal, closeTictactoe, endPlaydatePopup;

@synthesize space00, space01, space02, space10, space11, space12, space20, space21, space22, animateO, animateX;


// ## iOS default stuff start ###
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [playdate_id_label setText:[NSString stringWithFormat:@"%d",  self.playdate.playdateID]];
    [playmate_id_label setText:[NSString stringWithFormat:@"%d",  self.playmate_id]];
    [initiator_id_label setText:[NSString stringWithFormat:@"%d",  self.initiator_id]];
    [whose_turn_label setText:[NSString stringWithFormat:@"%d",  self->board_enabled]];
    [board_id_label setText:[NSString stringWithFormat:@"%d",  self->board_id]];

    
    // Add the ChatHUD view to the top of the screen
    self.chatView = [[PTChatHUDView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:self.chatView];
    [self setCurrentUserPhoto];
    [self setPlaymatePhoto];
    
    // Start listening to pusher notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pusherPlayDateTictactoePiecePlaced:) name:@"PlayDateTictactoePiecePlaced" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pusherPlayDateTictactoeEnd:) name:@"PlayDateTictactoeEndQuit" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pusherPlayDateTictactoeEnd:) name:@"PlayDateTictactoeEndCats" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pusherPlayDateTictactoeEnd:) name:@"PlayDateTictactoeEndLoss" object:nil];
    
    // Setup end playdate & close book buttons
    [endPlaydate setImage:[UIImage imageNamed:@"EndCallCrankPressed"] forState:UIControlStateHighlighted];
    [endPlaydate setImage:[UIImage imageNamed:@"EndCallCrankPressed"] forState:UIControlStateSelected];
    [closeTictactoe setImage:[UIImage imageNamed:@"CloseBookPressed"] forState:UIControlStateHighlighted];
    [closeTictactoe setImage:[UIImage imageNamed:@"CloseBookPressed"] forState:UIControlStateSelected];
    closeTictactoe.alpha = 0.0f;
    
    // Setup end playdate popup
    endPlaydatePopup.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"EndPlaydatePopupBg"]];
    endPlaydatePopup.hidden = YES;
}

// ## Tictactoe methods start ##
-(void)initGameWithMyTurn:(BOOL)myTurn
{
    //set turns accordingly
    self->board_enabled = (myTurn) ? YES : NO; //board_enabled indicates whose turn it is!

    //set the UIIMageViews for myPiece
    self->myPiece = ([self iAmX]) ? xStatic : yStatic;
    self->myPieceAnimated = ([self iAmX]) ? xAnimated : yAnimated;
    
    //set the turn based on if you're the initiator or not
    
}

-(IBAction)placePiece:(id)sender{
    if (self->board_enabled) { // TODOGIANCARLO why is this arrow notation?
        UIButton *button = (UIButton *)sender;
        NSInteger buttonTag = (NSInteger)[NSNumber numberWithInt:[button tag]];
        [whichButton setText:[NSString stringWithFormat:@"%d",  buttonTag]]; //TODOGIANCARLO ask ricky or dima if there's a better way to work with strings and numbers in objective C!!!
        
        //TOGGLE DISABLED BOARD STATE WHILE WAITING FOR SERVER REQUEST
        
        
        
        
        //HTTP POST TO SERVER
        
        
        
        //CALL METHOD TO DRAW THE X OR THE Y
    }
    else {
        //execute code here if the board is disabled
    }
}

- (void) disableBoard
{
    self->board_enabled = FALSE;
}
-(IBAction)endGame:(id)sender
{
    
}

// ## Helper methods start ###
- (BOOL) iAmX // TODOGIANCARLO test this!
{
    return [[PTUser currentUser] userID] == self.initiator_id;
}

// ## Playdate support start ###
- (void)setPlaydate:(PTPlaydate *)aPlaydate {
    LogDebug(@"Setting playdate");
    NSAssert(playdate == nil, @"Playdate already set");
    
    playdate = aPlaydate;
    [self wireUpwireUpPlaydateConnections];
}
- (void)wireUpwireUpPlaydateConnections {
    
    // The dialpad may already be subscribed to the playdate channel. When a playdate request
    // comes in on the dialpad, it subscribes to the playdate channel to catch end_playdate
    // messages. That way, it can deactivate the playmate button if the playmate ends the
    // playdate before the user accepts. In the instance where the user is not the initiator,
    // the playdate channel will already be subscribed by the time the PTDateViewController is
    // loaded. The check below is used to ensure the playdate channel is not yet subscribed to.
    if (![[PTPlayTellPusher sharedPusher] isSubscribedToPlaydateChannel]) {
        NSLog(@"Subscribing to channel: %@", self.playdate.pusherChannelName);
        [[PTPlayTellPusher sharedPusher] subscribeToPlaydateChannel:self.playdate.pusherChannelName];
    }
    
    // Notify server (and thus, the initiator) that we joined the playdate
    PTPlaydateJoinedRequest *playdateJoinedRequest = [[PTPlaydateJoinedRequest alloc] init];
    [playdateJoinedRequest playdateJoinedWithPlaydate:[NSNumber numberWithInteger:self.playdate.playdateID]
                                            authToken:[[PTUser currentUser] authToken]
                                            onSuccess:nil
                                            onFailure:nil
     ];
    
    [self setPlaymatePhoto];
    
    [[PTVideoPhone sharedPhone] setSessionConnectedBlock:^(OTStream *subscriberStream, OTSession *session, BOOL isSelf) {
        NSLog(@"Session connected!");
    }];
    
    NSString* myToken;
    if ([self.playdate isUserIDInitiator:[[PTUser currentUser] userID]]) {
        LogInfo(@"Current user is initator");
        myToken = playdate.initiatorTokboxToken;
    } else {
        LogInfo(@"Current user is NOT initiator");
        myToken = playdate.playmateTokboxToken;
    }
    
#ifndef TARGET_IPHONE_SIMULATOR
    [[PTVideoPhone sharedPhone] connectToSession:self.playdate.tokboxSessionID
                                       withToken:myToken
                                         success:^(OTPublisher *publisher)
     {
         if (publisher.publishVideo) {
             self.myPublisher = publisher;
             [self.chatView setRightView:publisher.view];
         }
     } failure:^(NSError *error) {
         LogError(@"Error connecting to video phone session: %@", error);
     }];
    
    [[PTVideoPhone sharedPhone] setSubscriberConnectedBlock:^(OTSubscriber *subscriber) {
        if (subscriber.stream.hasVideo) {
            self.playmateSubscriber = subscriber;
            [self.chatView setLeftView:subscriber.view];
        } else {
            [self.chatView transitionLeftImage];
        }
    }];
    
    [[PTVideoPhone sharedPhone] setSessionDropBlock:^(OTSession *session, OTStream *stream) {
        [self setPlaymatePhoto];
    }];
#endif
}
- (void)setCurrentUserPhoto {
    UIImage* myPhoto = [[PTUser currentUser] userPhoto];
    // If user photo is nil user the placeholder
    myPhoto = (myPhoto) ? [[PTUser currentUser] userPhoto] : [self placeholderImage];
    [self.chatView setLoadingImageForRightView:myPhoto];
}
- (void)setPlaymatePhoto {
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
- (UIImage*)placeholderImage {
    return [UIImage imageNamed:@"profile_default_2.png"];
}
- (IBAction)playdateDisconnect:(id)sender {
    // Notify server of disconnect
    [self disconnectPusherAndChat];
    if (self.playdate) {
        PTPlaydateDisconnectRequest *playdateDisconnectRequest = [[PTPlaydateDisconnectRequest alloc] init];
        [playdateDisconnectRequest playdateDisconnectWithPlaydateId:[NSNumber numberWithInt:playdate.playdateID]
                                                          authToken:[[PTUser currentUser] authToken]
                                                          onSuccess:^(NSDictionary* result)
         {
             // We delay moving to the dialpad because it will be checking for
             // playdates when it appears
             [self transitionToDialpad];
         }
                                                          onFailure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
         {
             [self transitionToDialpad];
         }];
    }
}
- (IBAction)endPlaydatePopupToggle:(id)sender {
    if (endPlaydatePopup.hidden) {
        endPlaydatePopup.hidden = NO;
    } else {
        endPlaydatePopup.hidden = YES;
    }
}
- (void)disconnectAndTransitionToDialpad {
    [self disconnectPusherAndChat];
    [self transitionToDialpad];
}
- (void)disconnectPusherAndChat {
    // Unsubscribe from playdate channel
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (self.playdate) {
        LogInfo(@"Unsubscribing from channel: %@", self.playdate.pusherChannelName);
        [[PTPlayTellPusher sharedPusher] unsubscribeFromPlaydateChannel:self.playdate.pusherChannelName];
    }
    
    [[PTVideoPhone sharedPhone] disconnect];
}
- (void)transitionToDialpad {
    PTAppDelegate* appDelegate = (PTAppDelegate*)[[UIApplication sharedApplication] delegate];
    if (appDelegate.dialpadController.loadingView != nil) {
        [appDelegate.dialpadController.loadingView removeFromSuperview];
    }
    [appDelegate.transitionController transitionToViewController:appDelegate.dialpadController
                                                     withOptions:UIViewAnimationOptionTransitionCrossDissolve];
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

// ## Testing start ###
- (IBAction)animationStartX:(id)sender {
    // create the view that will execute our animation
    CGRect imageframe = CGRectMake(220,200,124,90);
    UIImageView* spaceMarkedX = [[UIImageView alloc] initWithFrame:imageframe];
    
    // load all the frames of our animation
    spaceMarkedX.animationImages = [NSArray arrayWithObjects:
                                    [UIImage imageNamed:@"Comp 1_00000.png"],
                                    [UIImage imageNamed:@"Comp 1_00001.png"],
                                    [UIImage imageNamed:@"Comp 1_00002.png"],
                                    [UIImage imageNamed:@"Comp 1_00003.png"],
                                    [UIImage imageNamed:@"Comp 1_00004.png"],
                                    [UIImage imageNamed:@"Comp 1_00005.png"],
                                    [UIImage imageNamed:@"Comp 1_00005.png"],
                                    [UIImage imageNamed:@"Comp 1_00005.png"],
                                    [UIImage imageNamed:@"Comp 1_00005.png"],
                                    [UIImage imageNamed:@"Comp 1_00006.png"],
                                    [UIImage imageNamed:@"Comp 1_00007.png"],
                                    [UIImage imageNamed:@"Comp 1_00008.png"],
                                    [UIImage imageNamed:@"Comp 1_00009.png"],
                                    [UIImage imageNamed:@"Comp 1_00010.png"],
                                    [UIImage imageNamed:@"Comp 1_00011.png"],
                                    [UIImage imageNamed:@"Comp 1_00012.png"],
                                    [UIImage imageNamed:@"Comp 1_00013.png"], nil];
    NSLog(@"%@", spaceMarkedX.animationImages);
    
    
    
    // all frames will execute in 2 seconds
    spaceMarkedX.animationDuration = .5;
    // repeat the annimation forever
    spaceMarkedX.animationRepeatCount = 1;
    // start animating
    [spaceMarkedX startAnimating];
    // add the animation view to the main window
    [self.view addSubview:spaceMarkedX];
    
    
    
}
- (IBAction)animationStartO:(id)sender {
    // create the view that will execute our animation
    CGRect imageframe2 = CGRectMake(410,358,186,135);
    UIImageView* spaceMarkedO = [[UIImageView alloc] initWithFrame:imageframe2];
    
    // load all the frames of our animation
    spaceMarkedO.animationImages = [NSArray arrayWithObjects:
                                    [UIImage imageNamed:@"tic-O_00000.png"],
                                    [UIImage imageNamed:@"tic-O_00001.png"],
                                    [UIImage imageNamed:@"tic-O_00002.png"],
                                    [UIImage imageNamed:@"tic-O_00003.png"],
                                    [UIImage imageNamed:@"tic-O_00004.png"],
                                    [UIImage imageNamed:@"tic-O_00005.png"],
                                    [UIImage imageNamed:@"tic-O_00005.png"],
                                    [UIImage imageNamed:@"tic-O_00005.png"],
                                    [UIImage imageNamed:@"tic-O_00005.png"],
                                    [UIImage imageNamed:@"tic-O_00006.png"],
                                    [UIImage imageNamed:@"tic-O_00007.png"],
                                    [UIImage imageNamed:@"tic-O_00008.png"],
                                    [UIImage imageNamed:@"tic-O_00009.png"],
                                    [UIImage imageNamed:@"tic-O_00010.png"],
                                    [UIImage imageNamed:@"tic-O_00011.png"],
                                    [UIImage imageNamed:@"tic-O_00012.png"],
                                    [UIImage imageNamed:@"tic-O_00013.png"], nil];
    NSLog(@"%@", spaceMarkedO.animationImages);
    
    // all frames will execute in 2 seconds
    spaceMarkedO.animationDuration = .5;
    // repeat the annimation forever
    spaceMarkedO.animationRepeatCount = 1;
    // start animating
    [spaceMarkedO startAnimating];
    // add the animation view to the main window
    [self.view addSubview:spaceMarkedO];
}

@end
