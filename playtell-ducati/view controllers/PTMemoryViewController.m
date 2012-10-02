//
//  PTMemoryViewController.m
//  playtell-ducati
//
//  Created by Giancarlo D on 9/16/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import "PTMemoryViewController.h"
#import "PTAppDelegate.h"
#import "TransitionController.h"
#import "PTPlaydate.h"
#import "PTMemoryGameCard.h"
#import "PTMemoryGameBoard.h"
#import "PTUser.h"
#import "PTDialpadViewController.h"
#import "PTPlaydateDisconnectRequest.h"
#import "PTMemoryEndGameRequest.h"
#import "PTMemoryRefreshGameRequest.h"

#import <AVFoundation/AVFoundation.h>
#import <QuartzCore/QuartzCore.h>

@interface PTMemoryViewController ()
@property (nonatomic, weak) OTSubscriber* playmateSubscriber;
@property (nonatomic, weak) OTPublisher* myPublisher;   @property (nonatomic, retain) AVAudioPlayer* winPlayer;
@property (nonatomic, retain) AVAudioPlayer* lossPlayer;
@property (nonatomic, retain) AVAudioPlayer* xWritePlayer;
@property (nonatomic, retain) AVAudioPlayer* oWritePlayer;
@property (nonatomic, retain) AVAudioPlayer* missPlayer;
@property (nonatomic, retain) PTDateViewController* dateController;
@property (nonatomic, retain) AVAudioPlayer* strikeoutPlayer;

@end

@implementation PTMemoryViewController

@synthesize winPlayer, lossPlayer, xWritePlayer, oWritePlayer, missPlayer, strikeoutPlayer, dateController, playmateSubscriber, myPublisher, board, playdate;
@synthesize chatController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id) initializeWithmyTurn:(BOOL)myTurn
                boardID:(int)board_id
             playmateID:(int)playmate_id
            initiatorID:(int)initiator_id
            allFilenames:(NSArray *)filenames
            numCards:(int)num_cards
{
    //this will contain arrays of individual elements, like UIButtons for cards
    NSMutableArray *allVisualsCurrentlyOnBoard = [[NSMutableArray alloc] init];
    PTAppDelegate* appDelegate = (PTAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    PTPlaydate *playdate = appDelegate.dateViewController.playdate;
    
    //initialize the memoryBoard object
    PTMemoryGameBoard *gameBoard = [[PTMemoryGameBoard alloc] initMemoryGameBoardWithNumCards:num_cards isMyTurn:myTurn playdate:playdate.playdateID initiator:initiator_id playmate:playmate_id boardId:board_id filenameDict:filenames];
    [self setBoard:gameBoard];
    
    return self;
}

- (void) initGameVisually
{
    [self setupSounds];
    //listen for tictactoe pusher calls
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pusherPlayDateMemoryPlayTurn:) name:@"PlayDateMemoryPlacePiece" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pusherPlayDateMemoryEndGame:) name:@"PlayDateMemoryEndGame" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pusherPlayDateMemoryRefreshGame:) name:@"PlayDateMemoryRefreshGame" object:nil];

    //add board buttons to nsdictionary so they can be disabled
    board_cards = [[NSMutableArray alloc] initWithArray:[[self board] cardsOnBoard]];
}

- (void) createTurnIndicators:(bool)i_am_x
{
    CGRect opponentPlaceholderX = CGRectMake(254, 19, 35, 45);
    CGRect youPlaceholderX = CGRectMake(733, 19, 35, 45);
    CGRect opponentPlaceholderO = CGRectMake(249, 21.25, 39, 41);
    CGRect opponentO = CGRectMake(250, 14, 47, 55);
    CGRect opponentX = CGRectMake(250, 11.25, 43, 59);
    CGRect youPlaceholderO = CGRectMake(730, 19, 39, 41);
    CGRect youO = CGRectMake(725, 15, 47, 55);
    CGRect youX = CGRectMake(728, 10, 43, 59);
    
    if (!i_am_x) {
        UIImageView* youIndicator = [[UIImageView alloc] initWithFrame:youO];
        UIImageView* opponentIndicator = [[UIImageView alloc] initWithFrame:opponentX];
        
        youIndicator.image = [UIImage imageNamed:@"memory-turn-indicator.png"];
        opponentIndicator.image = [UIImage imageNamed:@"memory-turn-indicator.png"];
        
        [self.view addSubview:youIndicator];
        [self.view addSubview:opponentIndicator];
        
        self->board_turn_indicators = [[NSArray alloc] initWithObjects:youIndicator, opponentIndicator, nil];
    }
    else {
        UIImageView* youIndicator = [[UIImageView alloc] initWithFrame:youX];
        UIImageView* opponentIndicator = [[UIImageView alloc] initWithFrame:opponentO];
        
        youIndicator.image = [UIImage imageNamed:@"memory-turn-indicator.png"];
        opponentIndicator.image = [UIImage imageNamed:@"memory-turn-indicator.png"];
        
        [self.view addSubview:youIndicator];
        [self.view addSubview:opponentIndicator];
        
        self->board_turn_indicators = [[NSArray alloc] initWithObjects:youIndicator, opponentIndicator, nil];
    }
}

- (void) updateTurnIndicators:(BOOL)myTurn
{
    UIImageView *youIndicator = [self->board_turn_indicators objectAtIndex:0];
    UIImageView *opponentIndicator = [self->board_turn_indicators objectAtIndex:1];
    opponentIndicator.hidden = YES;
    youIndicator.hidden = YES;
    
    if (myTurn) {
        youIndicator.hidden = NO;
        //animate it
        [UIView beginAnimations:@"bounce" context:nil];
        [UIView setAnimationRepeatCount:2];
        [UIView setAnimationRepeatAutoreverses:YES];
        youIndicator.center = CGPointMake(youIndicator.center.x, youIndicator.center.y + 10);
        [UIView commitAnimations];
        [UIView beginAnimations:@"bounce" context:nil];
        [UIView setAnimationRepeatCount:2];
        [UIView setAnimationRepeatAutoreverses:YES];
        youIndicator.center = CGPointMake(youIndicator.center.x, youIndicator.center.y - 10);
        [UIView commitAnimations];
    }
    else {
        opponentIndicator.hidden = NO;
        //animate it!
        [UIView beginAnimations:@"bounce" context:nil];
        [UIView setAnimationRepeatCount:2];
        [UIView setAnimationRepeatAutoreverses:YES];
        opponentIndicator.center = CGPointMake(opponentIndicator.center.x, opponentIndicator.center.y + 10);
        [UIView commitAnimations];
        [UIView beginAnimations:@"bounce" context:nil];
        [UIView setAnimationRepeatCount:2];
        [UIView setAnimationRepeatAutoreverses:YES];
        opponentIndicator.center = CGPointMake(opponentIndicator.center.x, opponentIndicator.center.y - 10);
        [UIView commitAnimations];
    }
}

- (void) disableBoard {
    self->board_enabled = NO;
    //flip the board over, disable the buttons
    
    [self updateTurnIndicators:NO];
}

- (void) enableBoard {
    self->board_enabled = YES;
    
    //change opacity of all the cards!!!
    
    //flip the board over, enable the buttons
    [self updateTurnIndicators:YES];
}

-(void)reAddToBoard:(BOOL)myTurn
{
    NSEnumerator *e = [board_cards objectEnumerator];
    UIImageView *currentObject;
    while (currentObject = [e nextObject]) {
        if (!myTurn) {
            currentObject.alpha = .5;
        }
        else {
            currentObject.alpha = 1;
        }
        [self.view addSubview:currentObject];
    }
}
                                                  
-(void)clearBoard
{
    NSEnumerator *e = [board_cards objectEnumerator];
    UIImageView *currentObject;
    while (currentObject = [e nextObject]) {
        [currentObject removeFromSuperview];
    }
}          
                   
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    PTAppDelegate* appDelegate = (PTAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    appDelegate.memoryViewController = self;
    
    //add cards to board
    NSMutableArray *cardsOnBoard = [[self board] cardsOnBoard];
    int count = [cardsOnBoard count];
    for (int i = 0; i < count; i ++) {
        //set frame for UIButton
        PTMemoryGameCard *cardObject = [cardsOnBoard objectAtIndex:i];
        [cardObject.card setFrame:CGRectMake([[cardObject coordinates] boardX], [[cardObject coordinates] boardY], [cardObject cardWidth], [cardObject cardHeight])];

        [self.view addSubview:cardObject.card];
        NSLog(@"added a card");
    }
#if !(TARGET_IPHONE_SIMULATOR)
    [self.view addSubview:self.chatController.view];
#endif
    [self initGameVisually];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void) displayYouWin
{
    CGRect imageframe = CGRectMake(297,262,503,407);
    UIImageView *win = [[UIImageView alloc] initWithFrame:imageframe];
    
    win.image = [UIImage imageNamed:@"winner.png"];
    [self beginSound:(id)[NSNumber numberWithInt:WIN_SOUND]];
    
    //Set alpha
    win.alpha = 1;
    win.animationDuration = 5.75;
    [win startAnimating];
    
    //fade screen here
    [self.view addSubview:win];
    [self performSelector:@selector(newGame) withObject:nil afterDelay:2.0];
}

- (void) displayYouLost
{
    CGRect imageframe = CGRectMake(297,292,503,394);
    UIImageView *defeat = [[UIImageView alloc] initWithFrame:imageframe];
    
    defeat.image = [UIImage imageNamed:@"defeated.png"];
    [self beginSound:(id)[NSNumber numberWithInt:LOSS_SOUND]];
    
    defeat.animationDuration = 5.75;
    //Set alpha
    defeat.alpha = 1;
    [defeat startAnimating];
    
    //TODOGIANCARLO fade screen here
    [self.view addSubview:defeat];
}

- (void)beginSound:(id)soundId
{
    int theSound = [(NSNumber *)soundId integerValue];
    
    if (theSound == X_SOUND)
    {
        [self.xWritePlayer play];
    }
    if (theSound == O_SOUND)
    {
        [self.oWritePlayer play];
        
    }
    if (theSound == MISS_SOUND)
    {
        [self.missPlayer play];
        
    }
    if (theSound == STRIKEOUT_SOUND)
    {
        [self.strikeoutPlayer play];
        
    }
    if (theSound == WIN_SOUND)
    {
        [self.winPlayer play];
        
    }
    if (theSound == LOSS_SOUND)
    {
        [self.lossPlayer play];
        
    }
}

- (void)endSound:(int)theSound
{
    if (theSound == X_SOUND)
    {
        [self.xWritePlayer stop];
    }
    if (theSound == O_SOUND)
    {
        [self.oWritePlayer stop];
    }
    if (theSound == MISS_SOUND)
    {
        [self.missPlayer stop];
    }
    if (theSound == STRIKEOUT_SOUND)
    {
        [self.strikeoutPlayer stop];
    }
    if (theSound == WIN_SOUND)
    {
        [self.winPlayer stop];
    }
    if (theSound == LOSS_SOUND)
    {
        [self.lossPlayer stop];
    }
    
}

- (void)setupSounds {
    NSError *playerError;
    NSURL *win = [[NSBundle mainBundle] URLForResource:@"winner-applause" withExtension:@"wav"];
    NSURL *loss = [[NSBundle mainBundle] URLForResource:@"winner-gong" withExtension:@"aiff"];
    NSURL *xWrite = [[NSBundle mainBundle] URLForResource:@"X-Pen" withExtension:@"wav"];
    NSURL *oWrite = [[NSBundle mainBundle] URLForResource:@"O-Pen" withExtension:@"mp3"];
    NSURL *miss = [[NSBundle mainBundle] URLForResource:@"wiff" withExtension:@"wav"];
    NSURL *strikeout = [[NSBundle mainBundle] URLForResource:@"sword-hit" withExtension:@"wav"];
    
    
    self.winPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:win error:&playerError];
    self.lossPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:loss error:&playerError];
    self.xWritePlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:xWrite error:&playerError];
    self.oWritePlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:oWrite error:&playerError];
    self.missPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:miss error:&playerError];
    self.strikeoutPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:strikeout error:&playerError];
    
    self.winPlayer.volume = 0.75;
    self.winPlayer.numberOfLoops = .5;
    
    self.lossPlayer.volume = 0.75;
    self.lossPlayer.numberOfLoops = .5;
    
    self.xWritePlayer.volume = 0.75;
    self.xWritePlayer.numberOfLoops = .5;
    self.oWritePlayer.volume = 0.5;
    self.oWritePlayer.numberOfLoops = .5;
    
    self.missPlayer.volume = 0.75;
    self.missPlayer.numberOfLoops = .5;
    
    self.strikeoutPlayer.volume = 0.75;
    self.strikeoutPlayer.numberOfLoops = .5;
}

// ## Tictactoe methods start ##
-(void)initGameWithMyTurn:(BOOL)myTurn
{
    (myTurn) ? [self createTurnIndicators:YES] : [self createTurnIndicators:NO];
//    (myTurn) ? [self enableBoard] : [self disableBoard];
}

- (void)updateUIWithStatus:(int)status
               card1Index:(int)card1_index
                card2Index:(int)card2_index
                 winStatus:(int)winStatus
             isCurrentUser:(BOOL)isCurrentUser

{
    if (card2_index == -1) {
        
    }
    else {
        
    }
    if (status == FLIP_FIRST_CARD) {
        PTMemoryGameCard *cardToFlip = [[[self board] cardsOnBoard] objectAtIndex:card1_index];
        [cardToFlip flipCardAnimation];
    }
//    if (status == PLACED_SUCCESS) {
//        [self beginSound:(id)[NSNumber numberWithInt:soundKind]];
//        (isCurrentUser) ? [self drawMoveWithCoordinates:coordinates pieceKind:pieceKind opaque:NO] : [self drawMoveWithCoordinates:coordinates pieceKind:pieceKind opaque:YES];
//        (isCurrentUser) ? [self performSelector:@selector(disableBoard) withObject:nil afterDelay:.1] : [self performSelector:@selector(enableBoard) withObject:nil afterDelay:.1];
//    }
//    if (status == PLACED_WON) {
//        [self beginSound:(id)[NSNumber numberWithInt:soundKind]];
//        (isCurrentUser) ? [self drawMoveWithCoordinates:coordinates pieceKind:pieceKind opaque:NO] : [self drawMoveWithCoordinates:coordinates pieceKind:pieceKind opaque:YES];
//        [self performSelector:@selector(slashAnimate:) withObject:(id)[NSNumber numberWithInt:winStatus] afterDelay:.4];
//        
//        (isCurrentUser) ? [self performSelector:@selector(displayYouWin) withObject:nil afterDelay:1.2] : [self performSelector:@selector(displayYouLost) withObject:nil afterDelay:1.2];
//    }
//    if (status == PLACED_CATS) {
//        [self beginSound:(id)[NSNumber numberWithInt:soundKind]];
//        (isCurrentUser) ? [self drawMoveWithCoordinates:coordinates pieceKind:pieceKind opaque:NO] : [self drawMoveWithCoordinates:coordinates pieceKind:pieceKind opaque:YES];
//        
//        [self performSelector:@selector(displayCats:) withObject:(id)[NSNumber numberWithBool:isCurrentUser] afterDelay:1.2];
//    }
}


- (void)pusherMemoryGameEndGame:(NSNotification *)notification {
    // # TODO IMPLEMENT ENDGAME ONCE API FINISHED #
    
        NSLog(@"End game pusher call received");
    
        NSDictionary *eventData = notification.userInfo;
        NSInteger initiatorId = [[eventData objectForKey:@"playmate_id"] integerValue]; //person who ended the game
    
        if (initiatorId != [[PTUser currentUser] userID]) { //if we weren't the ones who just placed!
            PTAppDelegate* appDelegate = (PTAppDelegate*)[[UIApplication sharedApplication] delegate];
            [appDelegate.transitionController transitionToViewController:[appDelegate dateViewController] withOptions:UIViewAnimationOptionTransitionCrossDissolve];
       }
}

-(IBAction)endGame:(id)sender
{    
        NSString *boardID = [NSString stringWithFormat:@"%d", self.board.board_id];
    
        PTMemoryEndGameRequest *endGameRequest = [[PTMemoryEndGameRequest alloc] init];
    
        [endGameRequest endGameWithBoardId:boardID
                                 authToken:[[PTUser currentUser] authToken]
                                    userId:[NSString stringWithFormat:@"%d", [[PTUser currentUser] userID]]
                                playdateId:[NSString stringWithFormat:@"%d", self.playdate.playdateID]
                                 onSuccess:^(NSDictionary *result) {
                                     NSLog(@"End game API call success");
    
                                 }
                                 onFailure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                     NSLog(@"End game API call failure");
                                 }];
    
    PTAppDelegate* appDelegate = (PTAppDelegate*)[[UIApplication sharedApplication] delegate];
    [appDelegate.transitionController transitionToViewController:[appDelegate dateViewController] withOptions:UIViewAnimationOptionTransitionCrossDissolve];
}

-(void)pusherPlayDateMemoryPlayTurn:(NSNotification *)notification {
    NSDictionary *eventData = notification.userInfo;
    int placement_code = [[eventData objectForKey:@"placement_status"] integerValue];
    int playmateId = [[eventData objectForKey:@"playmate_id"] integerValue];
    int card1Index = [[eventData objectForKey:@"card1_index"] integerValue];
    int card2Index = [[eventData objectForKey:@"card2_index"] integerValue];

    if (playmateId != [[PTUser currentUser] userID]) { //if we weren't the ones who just placed!
        int win_code = YOU_DID_NOT_WIN_YET;
        
        if (placement_code == MATCH_WINNER) {
            win_code = [[eventData objectForKey:@"win_code"] integerValue];
        }
        [self updateUIWithStatus:placement_code card1Index:card2Index card2Index:card2Index winStatus:win_code isCurrentUser:NO];
        NSLog(@"Incoming place_piece pusher request...");
    }
}


// # HELPER METHODS START #
- (void)transitionToDialpad {
    PTAppDelegate* appDelegate = (PTAppDelegate*)[[UIApplication sharedApplication] delegate];
    if (appDelegate.dialpadController.loadingView != nil) {
        [appDelegate.dialpadController.loadingView removeFromSuperview];
    }
    [appDelegate.transitionController transitionToViewController:appDelegate.dialpadController
                                                     withOptions:UIViewAnimationOptionTransitionCrossDissolve];
}

- (IBAction)endPlaydateHandle:(id)sender {
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

- (void)disconnectPusherAndChat {
    // Unsubscribe from playdate channel
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (self.playdate) {
        [[PTPlayTellPusher sharedPusher] unsubscribeFromPlaydateChannel:self.playdate.pusherChannelName];
    }
#if !(TARGET_IPHONE_SIMULATOR)
    [[PTVideoPhone sharedPhone] disconnect];
#endif
}

@end
