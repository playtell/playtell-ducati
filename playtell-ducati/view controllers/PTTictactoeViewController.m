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
#import "PTTictactoeNewGameRequest.h"

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

- (int)getPlaymateUserID
{
    if ([self.playdate isUserIDInitiator:[[PTUser currentUser] userID]]) {
        LogInfo(@"Current user is initator. Playmate is playmate.");
        return self.playdate.playmate.userID;
        
    } else {
        LogInfo(@"Current user is NOT initiator. Playmate is initiator");
        return self.playdate.initiator.userID;
    }
}

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

-(void)pusherPlayDateTictactoeNewBoard:(NSNotification *)notification {
    NSDictionary *eventData = notification.userInfo;
    NSInteger initiator_id = [[eventData objectForKey:@"initiator_id"] integerValue];
    NSInteger boardId = [[eventData objectForKey:@"board_id"] integerValue];
    
    if (initiator_id != [[PTUser currentUser] userID]) { //if we weren't the ones who just placed!
        
        PTAppDelegate* appDelegate = (PTAppDelegate*)[[UIApplication sharedApplication] delegate];
        
        PTTictactoeViewController *tictactoeVc = [[PTTictactoeViewController alloc] init];
        [tictactoeVc setPlaydate:self.playdate];
        [tictactoeVc initGameWithMyTurn:NO];
        tictactoeVc.board_id = boardId;
        tictactoeVc.playmate_id = [[PTUser currentUser] userID];
        tictactoeVc.initiator_id = initiator_id;
        
        //bring up the view controller of the new game!
        CGRect imageframe = CGRectMake(0,0,1024,768);
        
        UIImageView *splash =  [[UIImageView alloc] initWithFrame:imageframe];
        splash.image = [UIImage imageNamed:@"TTT-cover.png"];
        
        //bring up the view controller of the new game!
        [appDelegate.transitionController transitionToViewController:tictactoeVc
                                                         withOptions:UIViewAnimationOptionTransitionCrossDissolve withSplash:splash];

    }
}

-(void) newGame
{
    PTTictactoeNewGameRequest *newGameRequest = [[PTTictactoeNewGameRequest alloc] init];
    
    [newGameRequest newBoardWithPlaydateId:[NSNumber numberWithInt:playdate.playdateID]
                                 authToken:[[PTUser currentUser] authToken]
                              initiator_id:[NSNumber numberWithInt:[[PTUser currentUser] userID]]
                               playmate_id:[NSNumber numberWithInt:[self getPlaymateUserID]]
                                 onSuccess:^(NSDictionary *result)
     {
         NSLog(@"%@", result);
         
         NSString *pusher_board_id = [result valueForKey:@"board_id"];
         
         PTAppDelegate* appDelegate = (PTAppDelegate*)[[UIApplication sharedApplication] delegate];
         
         PTTictactoeViewController *tictactoeVc = [[PTTictactoeViewController alloc] init];
         [tictactoeVc setPlaydate:self.playdate];
         
         [tictactoeVc initGameWithMyTurn:YES];
         tictactoeVc.board_id = [pusher_board_id intValue];
         tictactoeVc.playmate_id = [self getPlaymateUserID];
         tictactoeVc.initiator_id = [[PTUser currentUser] userID];
         [tictactoeVc setChatController:self.chatController];
         
         CGRect imageframe = CGRectMake(0,0,1024,768);
         
         UIImageView *splash =  [[UIImageView alloc] initWithFrame:imageframe];
         splash.image = [UIImage imageNamed:@"TTT-cover.png"];
         
         //bring up the view controller of the new game!
         [appDelegate.transitionController transitionToViewController:tictactoeVc
                                                          withOptions:UIViewAnimationOptionTransitionCrossDissolve withSplash:splash];
     } onFailure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
         NSLog(@"%@", error);
         NSLog(@"%@", request);
         NSLog(@"%@", JSON);
     }];
    
}

-(void)reAddToBoard
{
    NSEnumerator *e = [board_spaces objectEnumerator];
    UIImageView *currentObject;
    while (currentObject = [e nextObject]) {
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
{
    CGRect imageframe = CGRectMake(coordinate.boardX,coordinate.boardY,SPACE_WIDTH,SPACE_HEIGHT);
    
    UIImageView* space = [[UIImageView alloc] initWithFrame:imageframe];
    
    NSMutableArray * array = (kind == PIECE_X) ? [self buildImageArrayWithStart:0 end:15 unique_identifier:@"X"] : [self buildImageArrayWithStart:0 end:15 unique_identifier:@"O"];
    
    space.animationImages = array;
    space.animationDuration = .1;
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
        array = [self buildImageArrayWithStart:2 end:15 unique_identifier:@"RL"];
        boardX = ROW_COORDINATE_0;
        boardY = COL_COORDINATE_0;
        endingImageName = @"RL_00015.png";   
        
        CGRect imageframe = CGRectMake(boardX,boardY,590,590);
        slash = [[UIImageView alloc] initWithFrame:imageframe];
    }
    if (win_status_code == PLACED_WON_COL_0) {
        array = [self buildImageArrayWithStart:2 end:15 unique_identifier:@"Vertical"];
        boardX = ROW_COORDINATE_0 - 10;
        boardY = COL_COORDINATE_0;
        endingImageName = @"Vertical_00015.png";
        
        CGRect imageframe = CGRectMake(boardX,boardY,200,576);
        slash = [[UIImageView alloc] initWithFrame:imageframe];
    }
    if (win_status_code == PLACED_WON_COL_1) {
        array = [self buildImageArrayWithStart:2 end:15 unique_identifier:@"Vertical"];
        boardX = ROW_COORDINATE_1 - 10;
        boardY = COL_COORDINATE_0;
        endingImageName = @"Vertical_00014.png";
        
        CGRect imageframe = CGRectMake(boardX,boardY,200,576);
        slash = [[UIImageView alloc] initWithFrame:imageframe];
    }
    if (win_status_code == PLACED_WON_COL_2) {
        array = [self buildImageArrayWithStart:2 end:15 unique_identifier:@"Vertical"];
        boardX = ROW_COORDINATE_2 - 10;
        boardY = COL_COORDINATE_0;
        endingImageName = @"Vertical_00014.png";
        
        CGRect imageframe = CGRectMake(boardX,boardY,200,576);
        slash = [[UIImageView alloc] initWithFrame:imageframe];
    }
    if (win_status_code == PLACED_WON_ROW_0) {
        array = [self buildImageArrayWithStart:0 end:15 unique_identifier:@"Horizontal"];
        boardY = COL_COORDINATE_0 + 20;
        boardX = ROW_COORDINATE_0;
        endingImageName = @"Horizontal_00015.png";
        
        CGRect imageframe = CGRectMake(boardX,boardY,588,98);
        slash = [[UIImageView alloc] initWithFrame:imageframe];
    }
    if (win_status_code == PLACED_WON_ROW_1) {
        array = [self buildImageArrayWithStart:0 end:14 unique_identifier:@"Horizontal"];
        boardY = COL_COORDINATE_1 + 20;
        boardX = ROW_COORDINATE_0;
        endingImageName = @"Horizontal_00014.png";
        
        CGRect imageframe = CGRectMake(boardX,boardY,594,99);
        slash = [[UIImageView alloc] initWithFrame:imageframe];
    }
    if (win_status_code == PLACED_WON_ROW_2) {
        array = [self buildImageArrayWithStart:0 end:14 unique_identifier:@"Horizontal"];
        boardY = COL_COORDINATE_2 + 20;
        boardX = ROW_COORDINATE_0;
        endingImageName = @"Horizontal_00014.png";
        
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

- (NSArray *) getTurnIndicators
{
    if ([turnIndicators count] < 1) {
        
        CGRect opponent = CGRectMake(150, 15, 100, 100);
        CGRect you = CGRectMake(750, 15, 100, 100);

        UIImageView* youIndicator = [[UIImageView alloc] initWithFrame:you];
        UIImageView* opponentIndicator = [[UIImageView alloc] initWithFrame:opponent];
        
        if ([self iAmX]) {
            youIndicator.image = [UIImage imageNamed:@"o-turn.png"];
            opponentIndicator.image = [UIImage imageNamed:@"x-turn.png"];
        }
        else {
            youIndicator.image = [UIImage imageNamed:@"x-turn.png"];
            opponentIndicator.image = [UIImage imageNamed:@"o-turn.png"];
        }
        
        [self.view addSubview:youIndicator];
        [self.view addSubview:opponentIndicator];
        turnIndicators = [[NSArray alloc] initWithObjects:youIndicator, opponentIndicator, nil];
    }
    return turnIndicators;
    
}

- (void) updateTurnIndicators
{
    NSArray *indicators = [self getTurnIndicators];
    
    UIImageView *youIndicator = [indicators objectAtIndex:0];
    UIImageView *opponentIndicator = [indicators objectAtIndex:1];
    opponentIndicator.hidden = YES;
    youIndicator.hidden = YES;
    
    if (self->board_enabled) {
        youIndicator.hidden = NO;
    }
    else {
        opponentIndicator.hidden = NO;
    }
}

-(void)pusherPlayDateTictactoePlacePiece:(NSNotification *)notification {
    NSDictionary *eventData = notification.userInfo;
    int placement_code = [[eventData objectForKey:@"placement_code"] integerValue];
    int playmate_id = [[eventData objectForKey:@"playmate_id"] integerValue];
    if (playmate_id != [[PTUser currentUser] userID]) { //if we weren't the ones who just placed!
        
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

    self.winPlayer.volume = 0.5;
    self.winPlayer.numberOfLoops = .5;
    
    self.lossPlayer.volume = 0.5;
    self.lossPlayer.numberOfLoops = .5;
    
    self.xWritePlayer.volume = 0.5;
    self.xWritePlayer.numberOfLoops = .5;
    self.oWritePlayer.volume = 0.5;
    self.oWritePlayer.numberOfLoops = .5;
    
    self.missPlayer.volume = 0.5;
    self.missPlayer.numberOfLoops = .5;
    
    self.strikeoutPlayer.volume = 0.5;
    self.strikeoutPlayer.numberOfLoops = .5;
}

- (void) initGameVisually
{
    [self setupSounds];
    
    //listen for tictactoe pusher calls
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pusherPlayDateTictactoePlacePiece:) name:@"PlayDateTictactoePlacePiece" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pusherPlayDateTictactoeEndGame:) name:@"PlayDateTictactoeEndGame" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pusherPlayDateTictactoeNewBoard:) name:@"PlayDateTictactoeNewGame" object:nil];
    
    //add board uibuttons to nsdictionary so they can be disabled!
    board_buttons = [[NSArray alloc] initWithObjects:space00, space01, space02, space10, space11, space12, space20, space21, space22, nil];
    board_spaces = [[NSMutableArray alloc] init];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //init board frame for first time
    CGRect imageframe = CGRectMake(236,191,596,577);
    board = [[UIImageView alloc] initWithFrame:imageframe];
    board.image = [UIImage imageNamed:@"game-board-you.png"];//init with normal board, flip once everything else initialized
    [self.view addSubview:board];
    [self.view addSubview:self.chatController.view];
    
    [self beginSound:(id)[NSNumber numberWithInt:LOSS_SOUND]];
    [self initGameVisually];

}

// ## Tictactoe methods start ##
-(void)initGameWithMyTurn:(BOOL)myTurn
{
    (myTurn) ? [self enableBoard] : [self disableBoard];
    [self performSelector:@selector(updateTurnIndicators) withObject:nil afterDelay:5.0];
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
        [self drawMoveWithCoordinates:coordinates pieceKind:pieceKind];
        (isCurrentUser) ? [self performSelector:@selector(disableBoard) withObject:nil afterDelay:.2] : [self performSelector:@selector(enableBoard) withObject:nil afterDelay:.2];
    }
    if (status == PLACED_WON) {
        [self beginSound:(id)[NSNumber numberWithInt:soundKind]];
        [self drawMoveWithCoordinates:coordinates pieceKind:pieceKind];
        [self performSelector:@selector(slashAnimate:) withObject:(id)[NSNumber numberWithInt:winStatus] afterDelay:.4];

        (isCurrentUser) ? [self performSelector:@selector(displayYouWin) withObject:nil afterDelay:1.2] : [self performSelector:@selector(displayYouLost) withObject:nil afterDelay:1.2];
    }
    if (status == PLACED_CATS) {
        [self beginSound:(id)[NSNumber numberWithInt:soundKind]];
        [self drawMoveWithCoordinates:coordinates pieceKind:pieceKind];
        
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
    
    [self.view addSubview:cats];
    [self beginSound:(id)[NSNumber numberWithInt:LOSS_SOUND]];
        
    if (sendNewGame) {[self performSelector:@selector(newGame) withObject:nil afterDelay:4.0];};
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

    [self.view addSubview:win];
    [self performSelector:@selector(newGame) withObject:nil afterDelay:4.0];
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
    
    [self updateTurnIndicators];
    
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
                        [self reAddToBoard];
                    }];
}

- (void) enableBoard {
    self->board_enabled = YES;
    //flip the board over, enable the buttons
    [self updateTurnIndicators];
    
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
                        [self reAddToBoard];
                    }];
}

//Client-side place piece API support
-(void)tryPlacePieceRequestWithCoordinates:(PTTictactoeCoordinate *)coordinate
userId:(NSString *)userID
{
    NSString *boardID = [NSString stringWithFormat:@"%d", self.board_id];
    
    PTTictactoePlacePieceRequest *placePieceRequest = [[PTTictactoePlacePieceRequest alloc] init];
    NSLog(@"Auth token is :%@",[[PTUser currentUser] authToken] );
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


//    if ([buttonTag isEqualToString:@"0"]) {
//        [self updateUIWithStatus:PLACED_WON coordinates:clientCoordinates winStatus:PLACED_WON_ACROSS_TOP_LEFT isCurrentUser:YES];
//    }
//    if ([buttonTag isEqualToString:@"1"]) {
//        [self updateUIWithStatus:PLACED_WON coordinates:clientCoordinates winStatus:PLACED_WON_ACROS_BOTTON_LEFT isCurrentUser:YES];
//    }
//    if ([buttonTag isEqualToString:@"2"]) {
//        [self updateUIWithStatus:PLACED_CATS coordinates:clientCoordinates winStatus:PLACED_WON_COL_2 isCurrentUser:YES];
//    }
//    if ([buttonTag isEqualToString:@"10"]) {
//        [self updateUIWithStatus:PLACED_WON coordinates:clientCoordinates winStatus:PLACED_WON_ROW_1 isCurrentUser:YES];
//    }
//    if ([buttonTag isEqualToString:@"20"]) {
//        [self updateUIWithStatus:PLACED_WON coordinates:clientCoordinates winStatus:PLACED_WON_ROW_2 isCurrentUser:YES];
//    }
//    [self updateUIWithStatus:PLACED_SUCCESS coordinates:clientCoordinates winStatus:0 isCurrentUser:YES];
    
    [self tryPlacePieceRequestWithCoordinates:clientCoordinates userId:userId];
}

- (void)pusherPlayDateTictactoeEndGame
{
    PTAppDelegate* appDelegate = (PTAppDelegate*)[[UIApplication sharedApplication] delegate];
    [appDelegate.transitionController transitionToViewController:[appDelegate dateViewController] withOptions:UIViewAnimationOptionTransitionCrossDissolve];
}

-(IBAction)endGame:(id)sender
{
    [self pusherPlayDateTictactoeEndGame];
}

// ## Helper methods start ###
- (BOOL) iAmX // TODOGIANCARLO test this!
{
    return [[PTUser currentUser] userID] == self.initiator_id;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}
                           

@end
