//
//  PTTictactoeViewController.m
//  playtell-ducati
//
//  Created by Giancarlo Daniele on 7/28/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import "PTTictactoeViewController.h"
#import <QuartzCore/QuartzCore.h>

#import "Logging.h"

#import "PTAppDelegate.h"
#import "PTCheckForPlaydateRequest.h"
#import "PTConcretePlaymateFactory.h"
#import "PTDateViewController.h"
#import "PTDialpadViewController.h"
#import "PTBookView.h"
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
#import "TargetConditionals.h"
#import "PTTictactoeEndGameRequest.h"
#import "PTTictactoeRefreshGameRequest.h"

//tictactoe stuff
#import "PTTictactoeViewController.h"
#import "PTTictactoePlacePieceRequest.h"
#import "PTTictactoecoordinate.h"

#import <AVFoundation/AVFoundation.h>
#import <QuartzCore/QuartzCore.h>

@interface PTTictactoeViewController ()
@property (nonatomic, weak) OTSubscriber* playmateSubscriber;
@property (nonatomic, weak) OTPublisher* myPublisher;   @property (nonatomic, retain) AVAudioPlayer* winPlayer;
@property (nonatomic, retain) AVAudioPlayer* lossPlayer;
@property (nonatomic, retain) AVAudioPlayer* xWritePlayer;
@property (nonatomic, retain) AVAudioPlayer* oWritePlayer;
@property (nonatomic, retain) AVAudioPlayer* missPlayer;
@property (nonatomic, retain) PTDateViewController* dateController;
@property (nonatomic, retain) AVAudioPlayer* strikeoutPlayer;

@end

@implementation PTTictactoeViewController

@synthesize winPlayer, lossPlayer, xWritePlayer, oWritePlayer, missPlayer, strikeoutPlayer, dateController, board_id, playdate, playmateSubscriber, myPublisher, endPlaydate, endPlaydateForreal, closeTictactoe, endPlaydatePopup, space00, space01, space02, space10, space11, space12, space20, space21, space22, board;
@synthesize initiator_id, playmate_id;
@synthesize chatController;

-(NSString *)zeroFactory:(int)numZeros
{
    NSString *zeros = @"";
    for (int i = 0; i < numZeros; i++) {
        zeros = [zeros stringByAppendingString:@"0"];
    }
    return zeros;
}

-(int)getNumZeros:(int)currentNum
{
    if (currentNum < 10) {
        return 4;
    }
    else if (currentNum < 100) {
        return 3;
    }
    return 5;
}

-(NSMutableArray *)buildImageArrayWithStart:(int)start
                                        end:(int)end
                          unique_identifier:(NSString *)unique
{
    NSMutableArray *array = [NSMutableArray array];
    for (int i = start; i <= end; i++) {
        NSString *zeros = [self zeroFactory:[self getNumZeros:i]];
        
        NSString *filename = [NSString stringWithFormat:@"%@%@%@%@%@", unique, @"_", zeros, [NSString stringWithFormat:@"%d", i], @".png"];
        
        [array addObject:[UIImage imageNamed:filename]];
    }
    return array;
}

//server initiated new game
-(void)pusherPlayDateTictactoeRefreshGame:(NSNotification *)notification {
    NSDictionary *eventData = notification.userInfo;
    NSInteger initiatorId = [[eventData objectForKey:@"initiator_id"] integerValue];
    NSInteger boardId = [[eventData objectForKey:@"board_id"] integerValue];
    
    if (initiatorId != [[PTUser currentUser] userID]) { //if we weren't the ones who just placed!
        [self drawNewGame:boardId myTurn:NO initiator:initiatorId playmate:[[PTUser currentUser] userID]];
    }
}

-(void)drawNewGame:(int)boardId
          myTurn:(BOOL)isMyTurn
         initiator:(int)initiatorId
          playmate:(int)playmateId
{
    PTAppDelegate* appDelegate = (PTAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    PTTictactoeViewController *tictactoeVc = [[PTTictactoeViewController alloc] init];
    [tictactoeVc setPlaydate:self.playdate];
//#if !(TARGET_IPHONE_SIMULATOR)
    [tictactoeVc setChatController:self.chatController];
    [self.view addSubview:self.chatController.view];
//#endif
    tictactoeVc.board_id = boardId;
    if (isMyTurn) {
        tictactoeVc.initiator_id = initiatorId;
        tictactoeVc.playmate_id = playmateId;
        [tictactoeVc initGameWithMyTurn:YES];
    } else {
        tictactoeVc.initiator_id = initiatorId;
        tictactoeVc.playmate_id = playmateId;
        [tictactoeVc initGameWithMyTurn:NO];
    }
    [appDelegate.transitionController transitionToViewController:tictactoeVc
                                                     withOptions:UIViewAnimationOptionTransitionCrossDissolve];
}

//client initiated new game
-(void) newGame
{
    PTTictactoeRefreshGameRequest *newGameRequest = [[PTTictactoeRefreshGameRequest alloc] init];
    
    [newGameRequest refreshBoardWithPlaydateId:[NSNumber numberWithInt:playdate.playdateID]
                                 authToken:[[PTUser currentUser] authToken]
                                   playmate_id:[NSNumber numberWithInt:[self getOtherUserID]]
                               already_playing:@"yes"
                                initiatorId:[NSNumber numberWithInt:[[PTUser currentUser] userID]]
                                 onSuccess:^(NSDictionary *result)
     {
         NSLog(@"%@", result);
         
         NSString *boardId = [result valueForKey:@"board_id"];
         int boardID = [boardId intValue];
         [self drawNewGame:boardID myTurn:YES initiator:[[PTUser currentUser] userID] playmate:[self getOtherUserID]];
         
     } onFailure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
         NSLog(@"%@", error);
         NSLog(@"%@", request);
         NSLog(@"%@", JSON);
     }];
    
}

-(void)reAddToBoard:(BOOL)myTurn
{
    NSEnumerator *e = [board_spaces objectEnumerator];
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
    NSEnumerator *e = [board_spaces objectEnumerator];
    UIImageView *currentObject;
    while (currentObject = [e nextObject]) {
        [currentObject removeFromSuperview];
       }
}

- (void)drawMoveWithCoordinates:(PTTictactoeCoordinate *)coordinate
                             pieceKind:(int)kind
                             opaque:(BOOL)opaque
{
    CGRect imageframe = CGRectMake(coordinate.boardX,coordinate.boardY,SPACE_WIDTH,SPACE_HEIGHT);
    
    UIImageView* space = [[UIImageView alloc] initWithFrame:imageframe];
    
    NSMutableArray * array = (kind == PIECE_X) ? [self buildImageArrayWithStart:0 end:15 unique_identifier:@"X"] : [self buildImageArrayWithStart:1 end:15 unique_identifier:@"O"];
    
    space.animationImages = array;
    space.animationDuration = .1;
    space.alpha = (opaque) ? .5 : 1;
    space.animationRepeatCount = 1;
    space.image = (kind == PIECE_X) ? [UIImage imageNamed:@"X_00015.png"] : [UIImage imageNamed:@"O_00015.png"];
    
    [space startAnimating];
    // add the animation view to the main window
    [self.view addSubview:space];
    
    //add it to the nsarray to keep track of it!
    [board_spaces addObject:space];
}

- (void)slashAnimate:(id)winStatusCodeID
{
    
    NSNumber *winStatusCodeObject = (NSNumber *)winStatusCodeID;
    int win_status_code = [winStatusCodeObject integerValue];
    
    int boardX, boardY;
    NSMutableArray *array = [NSMutableArray array];
    NSString *endingImageName = @"";
    
    UIImageView* slash;
    
    if (win_status_code == PLACED_WON_ACROSS_TOP_LEFT) {
        array = [self buildImageArrayWithStart:0 end:14 unique_identifier:@"LR"];
        boardX = ROW_COORDINATE_0;
        boardY = COL_COORDINATE_0;
        endingImageName = @"LR_00014.png";
        
        CGRect imageframe = CGRectMake(boardX,boardY,590,590);
        slash = [[UIImageView alloc] initWithFrame:imageframe];
    }
    if (win_status_code == PLACED_WON_ACROS_BOTTON_LEFT) {
        array = [self buildImageArrayWithStart:2 end:14 unique_identifier:@"RL"];
        boardX = ROW_COORDINATE_0;
        boardY = COL_COORDINATE_0;
        endingImageName = @"RL_00014.png";   
        
        CGRect imageframe = CGRectMake(boardX,boardY,590,590);
        slash = [[UIImageView alloc] initWithFrame:imageframe];
    }
    if (win_status_code == PLACED_WON_COL_0) {
        array = [self buildImageArrayWithStart:0 end:15 unique_identifier:@"Vertical"];
        boardX = ROW_COORDINATE_0 - 10;
        boardY = COL_COORDINATE_0;
        endingImageName = @"Vertical_00015.png";
        
        CGRect imageframe = CGRectMake(boardX,boardY,200,576);
        slash = [[UIImageView alloc] initWithFrame:imageframe];
    }
    if (win_status_code == PLACED_WON_COL_1) {
        array = [self buildImageArrayWithStart:0 end:15 unique_identifier:@"Vertical"];
        boardX = ROW_COORDINATE_1 - 10;
        boardY = COL_COORDINATE_0;
        endingImageName = @"Vertical_00015.png";
        
        CGRect imageframe = CGRectMake(boardX,boardY,200,576);
        slash = [[UIImageView alloc] initWithFrame:imageframe];
    }
    if (win_status_code == PLACED_WON_COL_2) {
        array = [self buildImageArrayWithStart:0 end:15 unique_identifier:@"Vertical"];
        boardX = ROW_COORDINATE_2 - 10;
        boardY = COL_COORDINATE_0;
        endingImageName = @"Vertical_00015.png";
        
        CGRect imageframe = CGRectMake(boardX,boardY,200,576);
        slash = [[UIImageView alloc] initWithFrame:imageframe];
    }
    if (win_status_code == PLACED_WON_ROW_0) {
        array = [self buildImageArrayWithStart:1 end:15 unique_identifier:@"Horizontal"];
        boardY = COL_COORDINATE_0 + 20;
        boardX = ROW_COORDINATE_0;
        endingImageName = @"Horizontal_00015.png";
        
        CGRect imageframe = CGRectMake(boardX,boardY,588,98);
        slash = [[UIImageView alloc] initWithFrame:imageframe];
    }
    if (win_status_code == PLACED_WON_ROW_1) {
        array = [self buildImageArrayWithStart:1 end:14 unique_identifier:@"Horizontal"];
        boardY = COL_COORDINATE_1 + 20;
        boardX = ROW_COORDINATE_0;
        endingImageName = @"Horizontal_00015.png";
        
        CGRect imageframe = CGRectMake(boardX,boardY,594,99);
        slash = [[UIImageView alloc] initWithFrame:imageframe];
    }
    if (win_status_code == PLACED_WON_ROW_2) {
        array = [self buildImageArrayWithStart:1 end:15 unique_identifier:@"Horizontal"];
        boardY = COL_COORDINATE_2 + 20;
        boardX = ROW_COORDINATE_0;
        endingImageName = @"Horizontal_00015.png";
        
        CGRect imageframe = CGRectMake(boardX,boardY,594,99);
        slash = [[UIImageView alloc] initWithFrame:imageframe];
    }

    
    slash.image = [UIImage imageNamed:endingImageName];
    slash.animationImages = array;
    slash.animationDuration = .2;
    slash.animationRepeatCount = 1;
    
    [slash startAnimating];
    // add the animation view to the main window
    [self.view addSubview:slash];
    [self performSelector:@selector(beginSound:) withObject:(id)[NSNumber numberWithInt:STRIKEOUT_SOUND] afterDelay:.2];
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
        UIImageView* youPlaceholder = [[UIImageView alloc] initWithFrame:youPlaceholderO];
        UIImageView* opponentPlaceholder = [[UIImageView alloc] initWithFrame:opponentPlaceholderX];
        
        youIndicator.image = [UIImage imageNamed:@"o-turn.png"];                                                    
        opponentIndicator.image = [UIImage imageNamed:@"x-turn.png"];
        youPlaceholder.image = [UIImage imageNamed:@"o-placeholder"];
        opponentPlaceholder.image = [UIImage imageNamed:@"x-placeholder"];
        
        [self.view addSubview:youPlaceholder];
        [self.view addSubview:opponentPlaceholder];
        [self.view addSubview:youIndicator];
        [self.view addSubview:opponentIndicator];
        
        self->turn_indicators = [[NSArray alloc] initWithObjects:youIndicator, opponentIndicator, youPlaceholder, opponentPlaceholder, nil];
    }
    else {
        UIImageView* youIndicator = [[UIImageView alloc] initWithFrame:youX];
        UIImageView* opponentIndicator = [[UIImageView alloc] initWithFrame:opponentO];
        UIImageView* youPlaceholder = [[UIImageView alloc] initWithFrame:youPlaceholderX];
        UIImageView* opponentPlaceholder = [[UIImageView alloc] initWithFrame:opponentPlaceholderO];
        
        youIndicator.image = [UIImage imageNamed:@"x-turn.png"];
        opponentIndicator.image = [UIImage imageNamed:@"o-turn.png"];
        youPlaceholder.image = [UIImage imageNamed:@"x-placeholder"];
        opponentPlaceholder.image = [UIImage imageNamed:@"o-placeholder"];
        
        [self.view addSubview:youPlaceholder];
        [self.view addSubview:opponentPlaceholder];
        [self.view addSubview:youIndicator];
        [self.view addSubview:opponentIndicator];
        
        self->turn_indicators = [[NSArray alloc] initWithObjects:youIndicator, opponentIndicator, youPlaceholder, opponentPlaceholder, nil];
    }
}

- (void) updateTurnIndicators:(BOOL)myTurn
{
    UIImageView *youIndicator = [self->turn_indicators objectAtIndex:0];
    UIImageView *opponentIndicator = [self->turn_indicators objectAtIndex:1];
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

-(void)pusherPlayDateTictactoePlacePiece:(NSNotification *)notification {
    NSDictionary *eventData = notification.userInfo;
    int placement_code = [[eventData objectForKey:@"placement_code"] integerValue];
    int playmateId = [[eventData objectForKey:@"playmate_id"] integerValue];
    if (playmateId != [[PTUser currentUser] userID]) { //if we weren't the ones who just placed!
        
        NSString *coordinates = [eventData objectForKey:@"coordinates"];
        
        PTTictactoeCoordinate *pusherCoordinates = [[PTTictactoeCoordinate alloc] initWithCoordinateString:coordinates];
        
        int win_code = YOU_DID_NOT_WIN_YET;
        
        if (placement_code == PLACED_WON) {
            win_code = [[eventData objectForKey:@"win_code"] integerValue];
        }
        
        NSLog(@"Incoming place_piece pusher request...");
        
        [self updateUIWithStatus:placement_code coordinates:pusherCoordinates winStatus:win_code isCurrentUser:NO];
    }

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
    NSURL *oWrite = [[NSBundle mainBundle] URLForResource:@"O-Pen" withExtension:@"wav"];
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

- (void) initGameVisually
{
    [self setupSounds];
    
    //listen for tictactoe pusher calls
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pusherPlayDateTictactoePlacePiece:) name:@"PlayDateTictactoePlacePiece" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pusherPlayDateTictactoeEndGame:) name:@"PlayDateTictactoeEndGame" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pusherPlayDateTictactoeRefreshGame:) name:@"PlayDateTictactoeRefreshGame" object:nil];
    
    //add board uibuttons to nsdictionary so they can be disabled!
    board_buttons = [[NSArray alloc] initWithObjects:space00, space01, space02, space10, space11, space12, space20, space21, space22, nil];
    board_spaces = [[NSMutableArray alloc] init];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //init board frame for first time
    CGRect imageframe = CGRectMake(212,193,601,575);
    board = [[UIImageView alloc] initWithFrame:imageframe];
    board.image = [UIImage imageNamed:@"game-board-you.png"]; //init with normal board, flip once everything else initialized
    [self.view addSubview:board];
    
//#if !(TARGET_IPHONE_SIMULATOR)
    [self.view addSubview:self.chatController.view];
//#endif
    [self beginSound:(id)[NSNumber numberWithInt:LOSS_SOUND]];
    [self initGameVisually];
}

// ## Tictactoe methods start ##
-(void)initGameWithMyTurn:(BOOL)myTurn
{
    (myTurn) ? [self createTurnIndicators:YES] : [self createTurnIndicators:NO];
    (myTurn) ? [self enableBoard] : [self disableBoard];
}

- (void)updateUIWithStatus:(int)status
                coordinates:(PTTictactoeCoordinate *)coordinates
                                                   winStatus:(int)winStatus
                                                   isCurrentUser:(BOOL)isCurrentUser
                        
{
    int pieceKind;
    int soundKind;
    if (isCurrentUser) {
        pieceKind = ([self iAmX]) ? PIECE_X : PIECE_Y;
        soundKind = ([self iAmX]) ? X_SOUND : O_SOUND;
    }
    else {
        pieceKind = ([self iAmX]) ? PIECE_Y : PIECE_X;
        soundKind = ([self iAmX]) ? O_SOUND : X_SOUND;
    }
    
    if (status == NOT_PLACED) {
        if (isCurrentUser) { [self beginSound:(id)[NSNumber numberWithInt:MISS_SOUND]]; };
    }
    if (status == PLACED_SUCCESS) {
        [self beginSound:(id)[NSNumber numberWithInt:soundKind]];
        (isCurrentUser) ? [self drawMoveWithCoordinates:coordinates pieceKind:pieceKind opaque:NO] : [self drawMoveWithCoordinates:coordinates pieceKind:pieceKind opaque:YES];
        (isCurrentUser) ? [self performSelector:@selector(disableBoard) withObject:nil afterDelay:.1] : [self performSelector:@selector(enableBoard) withObject:nil afterDelay:.1];
    }
    if (status == PLACED_WON) {
        [self beginSound:(id)[NSNumber numberWithInt:soundKind]];
        (isCurrentUser) ? [self drawMoveWithCoordinates:coordinates pieceKind:pieceKind opaque:NO] : [self drawMoveWithCoordinates:coordinates pieceKind:pieceKind opaque:YES];
        [self performSelector:@selector(slashAnimate:) withObject:(id)[NSNumber numberWithInt:winStatus] afterDelay:.4];

        (isCurrentUser) ? [self performSelector:@selector(displayYouWin) withObject:nil afterDelay:1.2] : [self performSelector:@selector(displayYouLost) withObject:nil afterDelay:1.2];
    }
    if (status == PLACED_CATS) {
        [self beginSound:(id)[NSNumber numberWithInt:soundKind]];
        (isCurrentUser) ? [self drawMoveWithCoordinates:coordinates pieceKind:pieceKind opaque:NO] : [self drawMoveWithCoordinates:coordinates pieceKind:pieceKind opaque:YES];
        
        [self performSelector:@selector(displayCats:) withObject:(id)[NSNumber numberWithBool:isCurrentUser] afterDelay:1.2];
    }
}

- (void) displayCats:(id)currentUser
{
    BOOL sendNewGame = [(NSNumber *)currentUser boolValue];
    
    CGRect imageframe = CGRectMake(297,262,503,394);
    UIImageView *cats = [[UIImageView alloc] initWithFrame:imageframe];
    
    cats.image = [UIImage imageNamed:@"cats-game.png"];
    
    cats.animationDuration = 5.75;
    //Set alpha
    cats.alpha = 1;
    [cats startAnimating];
    
    //fade screen here
    [self.view addSubview:cats];
    [self beginSound:(id)[NSNumber numberWithInt:LOSS_SOUND]];
        
    if (sendNewGame) {[self performSelector:@selector(newGame) withObject:nil afterDelay:2.0];};
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

-(void)removeButtons
{
    NSEnumerator *e = [board_buttons objectEnumerator];
    UIButton *currentSpace;
    while (currentSpace = [e nextObject]) {
            [currentSpace removeFromSuperview];
    }
}

-(void)reAddButtons
{
    NSEnumerator *e = [board_buttons objectEnumerator];
    UIButton *currentSpace;
    while (currentSpace = [e nextObject]) {
        [self.view addSubview:currentSpace];
    }
}

- (void) disableBoard {
    self->board_enabled = NO;
    //flip the board over, disable the buttons
    
    [self updateTurnIndicators:NO];
    
    [UIView transitionWithView:self.board
                      duration:0.5f
                       options:UIViewAnimationOptionTransitionFlipFromLeft
                    animations:^{
                        [self removeButtons];
                        [self clearBoard];
                        board.image = [UIImage imageNamed:@"game-board-opponent.png"];
                    }
                    completion:^(BOOL finished){
                        [self reAddButtons];
                        [self reAddToBoard:NO];
                    }];
}

- (void) enableBoard {
    self->board_enabled = YES;
    
    [UIView transitionWithView:self.board
                      duration:0.5f
                       options:UIViewAnimationOptionTransitionFlipFromLeft
                    animations:^{
                        [self removeButtons];
                        [self clearBoard];
                        board.image = [UIImage imageNamed:@"game-board-you.png"];
                    }
                    completion:^(BOOL finished){
                        [self reAddButtons];
                        [self reAddToBoard:YES];
                    }];
    
    //flip the board over, enable the buttons
    [self updateTurnIndicators:YES];
}

//Client-side place piece API support
-(void)tryPlacePieceRequestWithCoordinates:(PTTictactoeCoordinate *)coordinate
userId:(NSString *)userID
{
    NSString *boardID = [NSString stringWithFormat:@"%d", self.board_id];
    
    PTTictactoePlacePieceRequest *placePieceRequest = [[PTTictactoePlacePieceRequest alloc] init];
    NSLog(@"Auth token is :%@",[[PTUser currentUser] authToken] );
    NSLog(@"user_id is :%@", userID);
    NSLog(@"board_id is :%@",boardID);
    NSLog(@"playdate_id is :%@",[NSString stringWithFormat:@"%d", self.playdate.playdateID]);
    [placePieceRequest placePieceWithCoordinates:coordinate.coordinateString
                                       authToken:[[PTUser currentUser] authToken]
                                    user_id:userID
                                        board_id:boardID
                                     playdate_id:[NSString stringWithFormat:@"%d", self.playdate.playdateID]
                                       with_json:@"false"
                                       onSuccess:^(NSDictionary *result) {
                                           NSNumber *pStatus = [result valueForKey:@"placement_code"];
                                           int placement_status = [pStatus intValue];
                                           
                                           int win_code = YOU_DID_NOT_WIN_YET;
                                           
                                           if (placement_status == PLACED_WON) {
                                               NSNumber *winCode = [result valueForKey:@"win_code"];
                                               win_code = [winCode intValue];
                                           }
                                           NSLog(@"%@", result);

                                           [self updateUIWithStatus:placement_status coordinates:coordinate winStatus:win_code isCurrentUser:YES];
                                       }
                                       onFailure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                           NSLog(@"Can't place piece. API returned error");
                                           [self beginSound:(id)[NSNumber numberWithInt:MISS_SOUND]];
                                           
                                           NSLog(@"%@", error);
                                           NSLog(@"%@", request);
                                           NSLog(@"%@", JSON);                                           
                                       }];
}

//Client-side place piece attempt
-(IBAction)placePiece:(id)sender{
    UIButton *button = (UIButton *)sender;
    NSString *buttonTag = [NSString stringWithFormat:@"%d", [button tag]]; //buttons are tagged with their coordinates in interface builder
    PTTictactoeCoordinate *clientCoordinates = [[PTTictactoeCoordinate alloc] initWithCoordinateString:buttonTag];
    NSString *userId = [NSString stringWithFormat:@"%d", [[PTUser currentUser] userID]];;
    
    [self tryPlacePieceRequestWithCoordinates:clientCoordinates userId:userId];
}

- (void)pusherPlayDateTictactoeEndGame:(NSNotification *)notification {
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
    NSString *boardID = [NSString stringWithFormat:@"%d", self.board_id];
    
    PTTictactoeEndGameRequest *endGameRequest = [[PTTictactoeEndGameRequest alloc] init];
    NSLog(@"Auth token is :%@",[[PTUser currentUser] authToken] );
    
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

// ## Helper methods start ###
- (BOOL) iAmX // TODOGIANCARLO test this!
{
    return [[PTUser currentUser] userID] == self.initiator_id;
}

- (int) getOtherUserID
{
    int myID = [[PTUser currentUser] userID];
    if (myID != self.playmate_id) {
        return self.playmate_id;
    }
    else {
        return self.initiator_id;
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

- (void)disconnectPusherAndChat {
    // Unsubscribe from playdate channel
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (self.playdate) {
        LogInfo(@"Unsubscribing from channel: %@", self.playdate.pusherChannelName);
        [[PTPlayTellPusher sharedPusher] unsubscribeFromPlaydateChannel:self.playdate.pusherChannelName];
    }
//#if !(TARGET_IPHONE_SIMULATOR)
    [[PTVideoPhone sharedPhone] disconnect];
//#endif
}

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

@end
