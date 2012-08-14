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
#import "TargetConditionals.h"
#import "PTTictactoeNewGameRequest.h"

//tictactoe stuff
#import "PTTictactoeViewController.h"
#import "PTTictactoePlacePieceRequest.h"
#import "PTTictactoecoordinate.h"

#import <AVFoundation/AVFoundation.h>
#import <QuartzCore/QuartzCore.h>

@interface PTTictactoeViewController ()
@property (nonatomic, strong) PTChatHUDView* chatView;
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

@synthesize winPlayer, lossPlayer, xWritePlayer, oWritePlayer, missPlayer, strikeoutPlayer, dateController, chatView, board_id, playdate, playmateSubscriber, myPublisher, endPlaydate, endPlaydateForreal, closeTictactoe, endPlaydatePopup, space00, space01, space02, space10, space11, space12, space20, space21, space22;

- (NSInteger)getPlaymateUserID
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

-(void) newGame
{
    PTTictactoeNewGameRequest *newGameRequest = [[PTTictactoeNewGameRequest alloc] init];
    
    [newGameRequest newBoardWithPlaydateId:[NSNumber numberWithInt:playdate.playdateID]
                                 authToken:[[PTUser currentUser] authToken]
                              initiator_id:[NSNumber numberWithInteger:self.initiator_id]
                               playmate_id:[NSNumber numberWithInteger:self.playmate_id]
                                 onSuccess:^(NSDictionary *result)
     {
         NSLog(@"%@", result);
         
         NSString *pusher_board_id = [result valueForKey:@"board_id"];
         
         PTTictactoeViewController *tictactoeVc = [[PTTictactoeViewController alloc] init];
         [tictactoeVc setPlaydate:self.playdate];
         
         BOOL isMyTurn = ([[PTUser currentUser] userID] == self.initiator_id) ? YES : NO; //TODOGIANCARLO come up with a better way to determine who goes first next time
         
         [tictactoeVc initGameWithMyTurn:isMyTurn];
         tictactoeVc.board_id = [pusher_board_id intValue];
         tictactoeVc.playmate_id = self.playmate_id;
         tictactoeVc.initiator_id = self.initiator_id;
         
         [self enableBoard];
         [self clearBoard];
     } onFailure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
         NSLog(@"%@", error);
         NSLog(@"%@", request);
         NSLog(@"%@", JSON);
     }];
    
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
    
    NSMutableArray * array = (kind == PIECE_X) ? [self buildImageArrayWithStart:0 end:71 unique_identifier:@"X"] : [self buildImageArrayWithStart:5 end:99 unique_identifier:@"O"];
    
    space.animationImages = array;
    space.animationDuration = .3;
    space.animationRepeatCount = 1;
    space.image = (kind == PIECE_X) ? [UIImage imageNamed:@"X_00071.png"] : [UIImage imageNamed:@"O_00109.png"];
    
    [space startAnimating];
    // add the animation view to the main window
    [self.view addSubview:space];
    
    //add it to the nsarray to keep track of it!
    [board_spaces addObject:space];
}

- (void)slashAnimate:(int)win_status_code
{
    int boardX, boardY;
    NSMutableArray *array = [NSMutableArray array];
    NSString *endingImageName = @"";
    
    UIImageView* slash;
    
    if (win_status_code == PLACED_WON_ACROSS_TOP_LEFT) {
        array = [self buildImageArrayWithStart:0 end:14 unique_identifier:@"LR"];
        boardX = ROW_COORDINATE_0;
        boardY = COL_COORDINATE_0;
        endingImageName = @"LR_00014.png";
        
        CGRect imageframe = CGRectMake(boardX,boardY,594,594);
        slash = [[UIImageView alloc] initWithFrame:imageframe];
    }
    if (win_status_code == PLACED_WON_ACROS_BOTTON_LEFT) {
        array = [self buildImageArrayWithStart:0 end:14 unique_identifier:@"RL"];
        boardX = ROW_COORDINATE_0;
        boardY = COL_COORDINATE_0;
        endingImageName = @"RL_00014.png";
        
        CGRect imageframe = CGRectMake(boardX,boardY,594,594);
        slash = [[UIImageView alloc] initWithFrame:imageframe];
    }
    if (win_status_code == PLACED_WON_COL_0) {
        array = [self buildImageArrayWithStart:0 end:14 unique_identifier:@"Vertical"];
        boardX = ROW_COORDINATE_0;
        boardY = COL_COORDINATE_0;
        endingImageName = @"Vertical_00014.png";
        
        CGRect imageframe = CGRectMake(boardX,boardY,200,576);
        slash = [[UIImageView alloc] initWithFrame:imageframe];
    }
    if (win_status_code == PLACED_WON_COL_1) {
        array = [self buildImageArrayWithStart:0 end:14 unique_identifier:@"Vertical"];
        boardX = ROW_COORDINATE_1;
        boardY = COL_COORDINATE_0;
        endingImageName = @"Vertical_00014.png";
        
        CGRect imageframe = CGRectMake(boardX,boardY,200,576);
        slash = [[UIImageView alloc] initWithFrame:imageframe];
    }
    if (win_status_code == PLACED_WON_COL_2) {
        array = [self buildImageArrayWithStart:0 end:14 unique_identifier:@"Vertical"];
        boardX = ROW_COORDINATE_2;
        boardY = COL_COORDINATE_0;
        endingImageName = @"Vertical_00014.png";
        
        CGRect imageframe = CGRectMake(boardX,boardY,200,576);
        slash = [[UIImageView alloc] initWithFrame:imageframe];
    }
    if (win_status_code == PLACED_WON_ROW_0) {
        array = [self buildImageArrayWithStart:0 end:14 unique_identifier:@"Horizontal"];
        boardY = COL_COORDINATE_0;
        boardX = ROW_COORDINATE_0;
        endingImageName = @"Horizontal_00014.png";
        
        CGRect imageframe = CGRectMake(boardX,boardY,594,99);
        slash = [[UIImageView alloc] initWithFrame:imageframe];
    }
    if (win_status_code == PLACED_WON_ROW_1) {
        array = [self buildImageArrayWithStart:0 end:14 unique_identifier:@"Horizontal"];
        boardY = COL_COORDINATE_1;
        boardX = ROW_COORDINATE_0;
        endingImageName = @"Horizontal_00014.png";
        
        CGRect imageframe = CGRectMake(boardX,boardY,594,99);
        slash = [[UIImageView alloc] initWithFrame:imageframe];
    }
    if (win_status_code == PLACED_WON_ROW_2) {
        array = [self buildImageArrayWithStart:0 end:14 unique_identifier:@"Horizontal"];
        boardY = COL_COORDINATE_2;
        boardX = ROW_COORDINATE_0;
        endingImageName = @"Horizontal_00014.png";
        
        CGRect imageframe = CGRectMake(boardX,boardY,594,99);
        slash = [[UIImageView alloc] initWithFrame:imageframe];
    }

    
    slash.image = [UIImage imageNamed:endingImageName];
    slash.animationImages = array;
    slash.animationDuration = 1;
    slash.animationRepeatCount = 1;
    
    [slash startAnimating];
    // add the animation view to the main window
    [self.view addSubview:slash];
}

- (NSArray *) getTurnIndicators
{
    if ([turnIndicators count] < 1) {
        
        CGRect opponent = CGRectMake(120, 25, SPACE_WIDTH, SPACE_HEIGHT);
        CGRect you = CGRectMake(750, 25, SPACE_WIDTH, SPACE_HEIGHT);

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
    
    //TODOGIANCARLO put this somewhere else
    if (self->board_enabled) {
        youIndicator.hidden = NO;
    }
    else {
        opponentIndicator.hidden = NO;
    }
}

- (void) updateDebugInfo
{
    [playdate_id_label setText:[NSString stringWithFormat:@"%d",  self.playdate.playdateID]];
    [playmate_id_label setText:[NSString stringWithFormat:@"%d",  self.playmate_id]];
    [initiator_id_label setText:[NSString stringWithFormat:@"%d",  self.initiator_id]];
    [board_id_label setText:[NSString stringWithFormat:@"%d",  self.board_id]];
    NSInteger turn =  (self->board_enabled) ? [[PTUser currentUser] userID] : [self getPlaymateUserID];
    [whose_turn_label setText:[NSString stringWithFormat:@"%d",  turn]];
    
    [playmate_id_label setHidden:YES];
    [playdate_id_label setHidden:YES];
    [board_id_label setHidden:YES];
    [whichButton setHidden:YES];
    [placement_status_label setHidden:YES];
    [initiator_id_label setHidden:YES];
    [whose_turn_label setHidden:YES];
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
        [self enableBoard];
    }

}

- (void)beginSound:(int)theSound
{
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
    NSURL *xWrite = [[NSBundle mainBundle] URLForResource:@"X-Pen" withExtension:@"mp3"];
    NSURL *oWrite = [[NSBundle mainBundle] URLForResource:@"O-Pen" withExtension:@"mp3"];
    NSURL *miss = [[NSBundle mainBundle] URLForResource:@"wiff" withExtension:@"wav"];
    NSURL *strikeout = [[NSBundle mainBundle] URLForResource:@"sword-hit" withExtension:@"wav"];


    self.winPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:win error:&playerError];
    self.lossPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:loss error:&playerError];
    self.xWritePlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:xWrite error:&playerError];
    self.oWritePlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:oWrite error:&playerError];
    self.missPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:miss error:&playerError];
    self.strikeoutPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:strikeout error:&playerError];

    self.winPlayer.volume = 0.25;
    self.winPlayer.numberOfLoops = 1;
    
    self.lossPlayer.volume = 0.25;
    self.lossPlayer.numberOfLoops = 1;
    
    self.xWritePlayer.volume = 0.25;
    self.xWritePlayer.numberOfLoops = 1;
    self.oWritePlayer.volume = 0.25;
    self.oWritePlayer.numberOfLoops = 1;
    
    self.missPlayer.volume = 0.25;
    self.missPlayer.numberOfLoops = 1;
    
    self.strikeoutPlayer.volume = 0.25;
    self.strikeoutPlayer.numberOfLoops = 1;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupSounds];
    
    //listen for tictactoe pusher calls
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pusherPlayDateTictactoePlacePiece:) name:@"PlayDateTictactoePlacePiece" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pusherPlayDateTictactoeEndGame:) name:@"PlayDateTictactoeEndGame" object:nil];
    
    //init indicator variables
    [self updateDebugInfo];

    // Add the ChatHUD view to the top of the screen
    self.chatView = [[PTChatHUDView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:self.chatView];
    [self setCurrentUserPhoto];
    [self setPlaymatePhoto];
    
    //add board uibuttons to nsdictionary so they can be disabled!
    board_buttons = [[NSArray alloc] initWithObjects:space00, space01, space02, space10, space11, space12, space20, space21, space22, nil];
    board_spaces = [[NSMutableArray alloc] init];

//    // Setup end playdate & close book buttons
//    [endPlaydate setImage:[UIImage imageNamed:@"EndCallCrankPressed"] forState:UIControlStateHighlighted];
//    [endPlaydate setImage:[UIImage imageNamed:@"EndCallCrankPressed"] forState:UIControlStateSelected];
//    
//    //TODOGIANCARLO why isnt this working
//    [closeTictactoe setImage:[UIImage imageNamed:@"CloseBookPressed"] forState:UIControlStateHighlighted];
//    [closeTictactoe setImage:[UIImage imageNamed:@"CloseBookPressed"] forState:UIControlStateSelected];
//    closeTictactoe.alpha = 0.0f;
    
//    // Setup end playdate popup
//    endPlaydatePopup.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"EndPlaydatePopupBg"]];
//    endPlaydatePopup.hidden = YES;
}

// ## Tictactoe methods start ##
-(void)initGameWithMyTurn:(BOOL)myTurn
{
    //set turns accordingly
//    self->board_enabled = (myTurn) ? YES : NO; //todogiancarlo fix this
    
    [self updateDebugInfo];
    [self updateTurnIndicators];
    [self enableBoard];
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
    }
    if (status == NOT_PLACED) {
        [self enableBoard];
        [self beginSound:MISS_SOUND];
    }
    if (status == PLACED_SUCCESS) {
        [self drawMoveWithCoordinates:coordinates pieceKind:pieceKind];
        [self beginSound:soundKind];
    }
    //the last person to put down the piece wins
    if (status == PLACED_WON) {
        [self drawMoveWithCoordinates:coordinates pieceKind:pieceKind];
        [self beginSound:soundKind];
        
        [self slashAnimate:winStatus];
        [self beginSound:STRIKEOUT_SOUND];


        if (isCurrentUser) {
            [self performSelector:@selector(displayYouWin) withObject:nil afterDelay:2.0];

        }
        else {
            [self performSelector:@selector(displayYouLost) withObject:nil afterDelay:2.0];
        }
        
        if ([[PTUser currentUser] userID] == self.initiator_id) {
            [self enableBoard];
        }
        [self enableBoard];
    }
    if (status == PLACED_CATS) {
        [self drawMoveWithCoordinates:coordinates pieceKind:pieceKind];
        [self slashAnimate:winStatus];
        //end game call to server
        
        if ([[PTUser currentUser] userID] == self.initiator_id) {
            [self enableBoard];
        }
        [self performSelector:@selector(displayCats) withObject:nil afterDelay:2.0];
        [self enableBoard];
    }
}

- (void) displayCats
{
    CGRect imageframe = CGRectMake(125,81,777,606);
    UIImageView *cats = [[UIImageView alloc] initWithFrame:imageframe];
    
    cats.image = [UIImage imageNamed:@"cats-game.png"];
    
    cats.animationDuration = 5.75;
    //Set alpha
    cats.alpha = 1;
    [cats startAnimating];
    
    [self.view addSubview:cats];
    [self beginSound:LOSS_SOUND];
    [self performSelector:@selector(newGame) withObject:nil afterDelay:2.0];
}

- (void) displayYouWin
{
    CGRect imageframe = CGRectMake(125,81,777,606);
    UIImageView *win = [[UIImageView alloc] initWithFrame:imageframe];
    
    win.image = [UIImage imageNamed:@"winner.png"];
    [self beginSound:WIN_SOUND];

    //Set alpha
    win.alpha = 1;
    win.animationDuration = 5.75;
    [win startAnimating];

    [self.view addSubview:win];
    [self performSelector:@selector(newGame) withObject:nil afterDelay:2.0];
}

- (void) displayYouLost
{
    CGRect imageframe = CGRectMake(125,81,777,606);
    UIImageView *defeat = [[UIImageView alloc] initWithFrame:imageframe];
    
    defeat.image = [UIImage imageNamed:@"defeated.png"];
    [self beginSound:LOSS_SOUND];

    defeat.animationDuration = 5.75;
    //Set alpha
    defeat.alpha = 1;
    [defeat startAnimating];
    
    [self.view addSubview:defeat];
    [self performSelector:@selector(newGame) withObject:nil afterDelay:2.0];    
}

- (void) disableBoard {
    self->board_enabled = NO;
    [self updateDebugInfo];
    [self updateTurnIndicators];

    //swap out the visuals and disable the buttons
    
//    NSEnumerator *e = [board_buttons objectEnumerator];
//    UIButton *currentSpace;
//    while (currentSpace = [e nextObject]) {
//        [currentSpace setEnabled:NO];
//    }
}

- (void) enableBoard {
    self->board_enabled = YES;
    [self updateDebugInfo];
    [self updateTurnIndicators];

    
    //swap out the visuals and enable the buttons
//    NSEnumerator *e = [board_buttons objectEnumerator];
//    UIButton *currentSpace;
//    while (currentSpace = [e nextObject]) {
//        [currentSpace setEnabled:YES];
//    }
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
                                           NSString *message = [result valueForKey:@"message"];
                                           [placement_status_label setText:message];
                                           
                                           int win_code = YOU_DID_NOT_WIN_YET;
                                           
                                           if (placement_status == PLACED_WON) {
                                               self->board_enabled = YES;
                                               [self enableBoard];
                                               NSNumber *winCode = [result valueForKey:@"win_code"];
                                               win_code = [winCode intValue];
                                           }
                                           
                                           [self updateUIWithStatus:placement_status coordinates:coordinate winStatus:win_code isCurrentUser:YES];
                                       }
                                       onFailure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                           NSLog(@"Can't place piece. API returned error");
                                           //TODOGIANCARLO placement status label
                                           [placement_status_label setText:@"Can't place piece. API returned error"];
                                           
                                           NSLog(@"%@", error);
                                           NSLog(@"%@", request);
                                           NSLog(@"%@", JSON);
                                           
                                           [self enableBoard];
                                       }];
}

//Client-side place piece attempt
-(IBAction)placePiece:(id)sender{
    [self displayCats];

    [self displayYouLost];

//CODE TO TEST SLASH ANIMATIONS
    UIButton *button = (UIButton *)sender;
    NSString *buttonTag = [NSString stringWithFormat:@"%d", [button tag]]; //buttons are tagged with their coordinates in interface builder
    [whichButton setText:buttonTag];

    if ([buttonTag isEqualToString:@"0"]) {
        [self slashAnimate:PLACED_WON_ROW_0];
        [self slashAnimate:PLACED_WON_COL_0];
        [self slashAnimate:PLACED_WON_ACROSS_TOP_LEFT];
    }
    if ([buttonTag isEqualToString:@"1"]) {
        [self slashAnimate:PLACED_WON_COL_1];
        
    }
    if ([buttonTag isEqualToString:@"2"]) {
        [self slashAnimate:PLACED_WON_COL_2];
    }
    if ([buttonTag isEqualToString:@"10"]) {
        [self slashAnimate:PLACED_WON_ROW_1];
    }
    if ([buttonTag isEqualToString:@"20"]) {
        [self slashAnimate:PLACED_WON_ROW_2];
        [self slashAnimate:PLACED_WON_ACROS_BOTTON_LEFT];
    }
    
    if (self->board_enabled) {
        [self disableBoard]; //disables board
        
        UIButton *button = (UIButton *)sender;
        NSString *buttonTag = [NSString stringWithFormat:@"%d", [button tag]]; //buttons are tagged with their coordinates in interface builder
        [whichButton setText:buttonTag];

        PTTictactoeCoordinate *clientCoordinates = [[PTTictactoeCoordinate alloc] initWithCoordinateString:buttonTag];
        NSString *userId = [NSString stringWithFormat:@"%d", [[PTUser currentUser] userID]];;
        [self tryPlacePieceRequestWithCoordinates:clientCoordinates userId:userId];
    }
    else {
        NSLog(@"Can't place piece. Not your turn!");
        [placement_status_label setText:@"Can't place piece. Not your turn!"];
        //play a sound here or toggle a state
    }
}

- (void)pusherPlayDateTictactoeEndGame
{
    self.dateController = [[PTDateViewController alloc] initWithNibName:@"PTDateViewController"
                                                                 bundle:nil];
    self.dateController.playdate = self.playdate;
    PTAppDelegate* appDelegate = (PTAppDelegate*)[[UIApplication sharedApplication] delegate];
    [appDelegate.transitionController transitionToViewController:self.dateController withOptions:UIViewAnimationOptionTransitionCrossDissolve];
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
                           

@end
