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
#import "PTUser.h"
#import "PTDialpadViewController.h"
#import "PTPlaydateDisconnectRequest.h"
#import "PTMemoryEndGameRequest.h"
#import "PTMemoryRefreshGameRequest.h"
#import "PTMemoryPlayTurnRequest.h"
#import <AVFoundation/AVFoundation.h>
#import <QuartzCore/QuartzCore.h>

@interface PTMemoryViewController ()
@end

@implementation PTMemoryViewController

@synthesize chatController;

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil
             playdate:(PTPlaydate *)_playdate
               myTurn:(BOOL)myTurn
              boardID:(NSInteger)_boardID
           playmateID:(NSInteger)_playmateID
          initiatorID:(NSInteger)_initiatorID
         allFilenames:(NSArray *)_filenames
             numCards:(NSInteger)_numCards {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Store data
        playdate = _playdate;
        boardID = _boardID;
        playmateID = _playmateID;
        initiatorID = _initiatorID;
        filenames = _filenames;
        numCards = _numCards;
        isMyTurn = myTurn;
        
        // Blank card indices
        cardIndex1 = nil;
        cardIndex2 = nil;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Setup tooltips
    ttWaitYourTurn = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 260.0f, 168.0f)];
    ttWaitYourTurn.center = CGPointMake([UIScreen mainScreen].bounds.size.height / 2.0f, [UIScreen mainScreen].bounds.size.width / 2.0f);
    ttWaitYourTurn.image = [UIImage imageNamed:@"wait-your-turn"];
    ttWaitYourTurn.hidden = YES;
    [self.view addSubview:ttWaitYourTurn];
    
    // Winner/loser views
    winnerView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 465.0f, 394.0f)];
    winnerView.center = ttWaitYourTurn.center;
    winnerView.image = [UIImage imageNamed:@"memory-win"];
    winnerView.alpha = 0.0f;
    loserView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 465.0f, 394.0f)];
    loserView.center = ttWaitYourTurn.center;
    loserView.image = [UIImage imageNamed:@"memory-loss"];
    loserView.alpha = 0.0f;
    
    // Add cards to board
    [self setupCards];

    // Display chat HUD?
    [self.view addSubview:self.chatController.view];
    
    // Setup end playdate & close book buttons
    endPlaydate.layer.shadowColor = [UIColor blackColor].CGColor;
    endPlaydate.layer.shadowOffset = CGSizeMake(0.0f, 2.0f);
    endPlaydate.layer.shadowOpacity = 0.2f;
    endPlaydate.layer.shadowRadius = 6.0f;
    
    // Listen to pusher events
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pusherPlayDateMemoryPlayTurn:) name:@"PlayDateMemoryPlayTurn" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pusherPlayDateMemoryEndGame:) name:@"PlayDateMemoryEndGame" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pusherPlayDateMemoryRefreshGame:) name:@"PlayDateMemoryRefreshGame" object:nil];
    
    // Setup sounds
    [self setupSounds];
    
    // Whose turn is it?
    if ([PTUser currentUser].userID == initiatorID) {
        [scoreViewMe showYourTurn:YES delay:YES];
    } else {
        [scoreViewOpponent showYourTurn:YES delay:YES];
    }
    
    // Set active chat HUD
    [self performSelector:@selector(setActiveChatHUD) withObject:nil afterDelay:0.5f];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)viewDidAppear:(BOOL)animated {
    // Show all cards
    [self showCards];
}

- (void)dealloc {
    // Notifications cleanup
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

#pragma mark - Tooltip methods

- (void)showWaitYourTurn {
    [ttWaitYourTurn.layer removeAllAnimations];
    ttWaitYourTurn.alpha = 0.0f;
    ttWaitYourTurn.hidden = NO;
    [UIView animateWithDuration:0.4f animations:^{
        ttWaitYourTurn.alpha = 1.0f;
    } completion:^(BOOL finished) {
        [self performSelector:@selector(hideWaitYourTurn) withObject:nil afterDelay:2.0f];
    }];
}

- (void)hideWaitYourTurn {
    [ttWaitYourTurn.layer removeAllAnimations];
    [UIView animateWithDuration:0.4f animations:^{
        ttWaitYourTurn.alpha = 0.0f;
    } completion:^(BOOL finished) {
        ttWaitYourTurn.hidden = YES;
    }];
}

#pragma mark - Card methods

- (void)setupCards {
    cards = [NSMutableArray arrayWithCapacity:[filenames count]];
    for (int i=0; i<[filenames count]; i++) {
        PTMemoryGameCard *card = [[PTMemoryGameCard alloc] initWithFrontFilename:[filenames objectAtIndex:i]
                                                                    backFilename:@"card-back"
                                                                    indexOnBoard:i
                                                                   numberOfCards:numCards];
        [card setFrame:CGRectMake(card.coordinates.boardX,
                                  card.coordinates.boardY,
                                  card.size.width,
                                  card.size.height)];
        card.containerView.hidden = YES;
        card.containerView.alpha = 0.0f;
        card.delegate = self;
        [self.view insertSubview:card.containerView belowSubview:ttWaitYourTurn];
        [cards addObject:card];
    }
}

- (void)showCards {
    for (PTMemoryGameCard *card in cards) {
        card.containerView.hidden = NO;
    }
    [UIView animateWithDuration:0.4f animations:^{
        for (PTMemoryGameCard *card in cards) {
            card.containerView.hidden = NO;
            card.containerView.alpha = 1.0f;
        }
    }];
}

- (PTMemoryGameCard *)getCardByIndex:(NSInteger)index {
    if (index < [cards count]) {
        return (PTMemoryGameCard *)[cards objectAtIndex:index];
    }
    return nil;
}

- (void)disableCards {
    for (PTMemoryGameCard *card in cards) {
        [card disableCard];
    }
}

- (void)enableCards {
    for (PTMemoryGameCard *card in cards) {
        [card enableCard];
    }
}

- (void)removeCards {
    for (PTMemoryGameCard *card in cards) {
        [card.containerView removeFromSuperview];
    }
    cards = nil;
}

#pragma mark - Sound methods

- (void)beginSound:(id)soundId {
    int theSound = [(NSNumber *)soundId integerValue];

    switch (theSound) {
        case MISS_SOUND:
            [soundMiss play];
            break;
        case WIN_SOUND:
            [soundWin play];
            break;
        case LOSS_SOUND:
            [soundLoss play];
            break;
    }
}

- (void)endSound:(int)theSound {
    switch (theSound) {
        case MISS_SOUND:
            [soundMiss stop];
            break;
        case WIN_SOUND:
            [soundWin stop];
            break;
        case LOSS_SOUND:
            [soundLoss stop];
            break;
    }
}

- (void)setupSounds {
    NSError *playerError;
    NSURL *win = [[NSBundle mainBundle] URLForResource:@"winner-applause" withExtension:@"mp3"];
    NSURL *loss = [[NSBundle mainBundle] URLForResource:@"winner-gong" withExtension:@"aiff"];
    NSURL *miss = [[NSBundle mainBundle] URLForResource:@"wiff" withExtension:@"wav"];
    
    soundWin = [[AVAudioPlayer alloc] initWithContentsOfURL:win error:&playerError];
    soundLoss = [[AVAudioPlayer alloc] initWithContentsOfURL:loss error:&playerError];
    soundMiss = [[AVAudioPlayer alloc] initWithContentsOfURL:miss error:&playerError];
    
    soundWin.volume = 0.75f;
    soundWin.numberOfLoops = .5f;
    
    soundMiss.volume = 0.75f;
    soundMiss.numberOfLoops = .5f;
    
    soundMiss.volume = 0.75f;
    soundMiss.numberOfLoops = .5f;
}

#pragma mark - Game update UI methods

- (void)displayYouWin {
    [self.view addSubview:winnerView];
    [UIView animateWithDuration:0.4f animations:^{
        winnerView.alpha = 1.0f;
    }];
}

- (void)displayYouLost {
    [self.view addSubview:loserView];
    [UIView animateWithDuration:0.4f animations:^{
        loserView.alpha = 1.0f;
    }];
}

- (void)resetGame {
    // Since inititor may have changed, find out real playmate
    // It changes if user that won wasn't the original initiator
    // If they won, they should be the new initiator so they can have the first turn
    NSInteger newPlaymateId;
    if ([PTUser currentUser].userID == initiatorID) {
        newPlaymateId = playmateID;
    } else {
        newPlaymateId = initiatorID;
    }

    // API call to reset the game
    NSInteger randNumCards = 2 * (arc4random_uniform(4) + 2); // Random number from 2 to 6 multiplied by 2 to get an even number from 2 to 12
    PTMemoryRefreshGameRequest *memoryRefreshGameRequest = [[PTMemoryRefreshGameRequest alloc] init];
    [memoryRefreshGameRequest refreshBoardWithPlaydateId:[NSNumber numberWithInteger:playdate.playdateID]
                                               authToken:[PTUser currentUser].authToken
                                             playmate_id:[NSString stringWithFormat:@"%i", newPlaymateId]
                                             initiatorId:[NSString stringWithFormat:@"%i", [PTUser currentUser].userID]
                                               onSuccess:nil
                                                theme_ID:@"19"
                                         num_total_cards:[NSString stringWithFormat:@"%i", randNumCards]
                                         already_playing:@"YES"
                                               onFailure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                   NSLog(@"Error: %@", error);
                                                   NSLog(@"Error: %@", JSON);
                                               }];
}

- (void)handleGameTurnWithStatusCode:(NSInteger)statusCode
                          playmateId:(NSInteger)currentPlayerId
                                turn:(NSInteger)whoseTurn
                      initiatorScore:(NSInteger)initiatorScore
                       playmateScore:(NSInteger)playmateScore
                            winnerId:(NSNumber *)winnderId {

    switch (statusCode) {
        // Match found!
        case MATCH_FOUND: {
            NSLog(@"Match found! Disabling cards. Updating score. Same user can continue.");
            // Disable both cards (aka. take them out of the game)
            PTMemoryGameCard *card1 = (PTMemoryGameCard *)[cards objectAtIndex:[cardIndex1 integerValue]];
            PTMemoryGameCard *card2 = (PTMemoryGameCard *)[cards objectAtIndex:[cardIndex2 integerValue]];
            [card1 jumpUpDownDelayed:YES];
            [card2 jumpUpDownDelayed:YES];

            // Reset card indices
            cardIndex1 = nil;
            cardIndex2 = nil;

            // Update score
            [self updateScoresWithInitiatorScore:initiatorScore playmateScore:playmateScore];
            break;
        }
        
        // Cards do not match
        case MATCH_ERROR: {
            NSLog(@"Cards not matched. Flipping them back. Switching turn.");
            // Flip both cards back
            PTMemoryGameCard *card1 = (PTMemoryGameCard *)[cards objectAtIndex:[cardIndex1 integerValue]];
            PTMemoryGameCard *card2 = (PTMemoryGameCard *)[cards objectAtIndex:[cardIndex2 integerValue]];
            [card1 jumpLeftRightDelayed:YES];
            [card2 jumpLeftRightDelayed:YES];
            
            // Reset card indices
            cardIndex1 = nil;
            cardIndex2 = nil;
            
            // Switch whose turn it is
            isMyTurn = !isMyTurn;

            // Visually let person know it's their turn now
            if (isMyTurn == YES) {
                [scoreViewMe showYourTurn:YES delay:YES];
                [scoreViewOpponent showYourTurn:NO delay:YES];
            } else {
                [scoreViewMe showYourTurn:NO delay:YES];
                [scoreViewOpponent showYourTurn:YES delay:YES];
            }
            
            // Set active chat HUD
            [self performSelector:@selector(setActiveChatHUD) withObject:nil afterDelay:2.0f];
            
            NSLog(@"Is it your turn? %@", isMyTurn ? @"YES" : @"NO");
            break;
        }
            
        // First card was flipped
        case FLIP_FIRST_CARD: {
            // This case will never occur since this function isn't called until both cards are flipped!
            break;
        }
            
        // Match won!
        case MATCH_WINNER: {
            NSLog(@"Match won!");
            // Disable both cards (aka. take them out of the game)
            PTMemoryGameCard *card1 = (PTMemoryGameCard *)[cards objectAtIndex:[cardIndex1 integerValue]];
            PTMemoryGameCard *card2 = (PTMemoryGameCard *)[cards objectAtIndex:[cardIndex2 integerValue]];
            [card1 jumpUpDown];
            [card2 jumpUpDown];

            // Show winner/loser views
            if ([winnderId integerValue] == [PTUser currentUser].userID) {
                [self performSelector:@selector(displayYouWin) withObject:nil afterDelay:1.5f];
            } else {
                [self performSelector:@selector(displayYouLost) withObject:nil afterDelay:1.5f];
            }

            // Update scores
            [self updateScoresWithInitiatorScore:initiatorScore playmateScore:playmateScore];

            // Start new game after timeout (let the winner fire off new game call!)
            if ([winnderId integerValue] == [PTUser currentUser].userID) {
                [self performSelector:@selector(resetGame) withObject:nil afterDelay:6.0f];
            }
            break;
        }
    }
}

- (void)updateScoresWithInitiatorScore:(NSInteger)initiatorScore playmateScore:(NSInteger)playmateScore {
    NSInteger scoreMe;
    NSInteger scoreOpponent;
    
    // Which score is which?
    if ([PTUser currentUser].userID == initiatorID) {
        scoreMe = initiatorScore;
        scoreOpponent = playmateScore;
    } else {
        scoreMe = playmateScore;
        scoreOpponent = initiatorScore;
    }
    
    // Update labels
    [scoreViewMe setScore:scoreMe];
    [scoreViewOpponent setScore:scoreOpponent];
}

- (void)setActiveChatHUD {
    // Change active HUD
    if (isMyTurn == YES) {
        [self.chatController setActiveTurnToRightChatView];
    } else {
        [self.chatController setActiveTurnToLeftChatView];
    }
}

#pragma mark - End game methods

- (IBAction)endGame:(id)sender {
    // API call to end the game
    PTMemoryEndGameRequest *endGameRequest = [[PTMemoryEndGameRequest alloc] init];
    [endGameRequest endGameWithBoardId:[NSString stringWithFormat:@"%i", boardID]
                             authToken:[[PTUser currentUser] authToken]
                                userId:[NSString stringWithFormat:@"%d", [[PTUser currentUser] userID]]
                            playdateId:[NSString stringWithFormat:@"%d", playdate.playdateID]
                             onSuccess:nil
                             onFailure:nil];
    
    // Transition to playdate view controller
    PTAppDelegate* appDelegate = (PTAppDelegate*)[[UIApplication sharedApplication] delegate];
    [appDelegate.transitionController transitionToViewController:[appDelegate dateViewController] withOptions:UIViewAnimationOptionTransitionCrossDissolve];
}

#pragma mark - Pusher event handlers

- (void)pusherPlayDateMemoryEndGame:(NSNotification *)notification {
    NSDictionary *eventData = notification.userInfo;
    NSInteger initiatorId = [[eventData objectForKey:@"playmate_id"] integerValue]; // Who ended the game
    
    if (initiatorId != [[PTUser currentUser] userID]) { // Skip if we are the ones who ended the game
        // Transition to playdate view controller
        PTAppDelegate* appDelegate = (PTAppDelegate*)[[UIApplication sharedApplication] delegate];
        [appDelegate.transitionController transitionToViewController:[appDelegate dateViewController] withOptions:UIViewAnimationOptionTransitionCrossDissolve];
    }
}

- (void)pusherPlayDateMemoryPlayTurn:(NSNotification *)notification {
    NSDictionary *eventData = notification.userInfo;
    NSInteger statusCode = [[eventData objectForKey:@"status"] integerValue];
    NSInteger currentPlayerId = [[eventData objectForKey:@"playmate_id"] integerValue];
    NSInteger whoseTurn = [[eventData objectForKey:@"turn"] integerValue];

    // Verify that it wasn't us who took this turn
    if (currentPlayerId != [[PTUser currentUser] userID]) {
        // Update card indices
        NSNumber *card1 = [eventData objectForKey:@"card1_index"];
        NSNumber *card2 = [eventData objectForKey:@"card2_index"];
        cardIndex1 = [card1 isKindOfClass:[NSNull class]] ? nil : card1; // Save nils, not NSNull class
        cardIndex2 = [card2 isKindOfClass:[NSNull class]] ? nil : card2; // Save nils, not NSNull class

        // Flip the appropriate card
        PTMemoryGameCard *card;
        if (cardIndex2 == nil) {
            card = (PTMemoryGameCard *)[cards objectAtIndex:[cardIndex1 integerValue]];
        } else {
            card = (PTMemoryGameCard *)[cards objectAtIndex:[cardIndex2 integerValue]];
        }
        [card flipCard];
        
        // Now that 2 cards have been flipped, verify next steps
        if (cardIndex1 != nil && cardIndex2 != nil) {
            NSInteger initiatorScore = [[eventData objectForKey:@"initiator_score"] integerValue];
            NSInteger playmateScore = [[eventData objectForKey:@"playmate_score"] integerValue];
            NSNumber *winnerId = [eventData objectForKey:@"winner_id"];
            [self handleGameTurnWithStatusCode:statusCode
                                    playmateId:currentPlayerId
                                          turn:whoseTurn
                                initiatorScore:initiatorScore
                                 playmateScore:playmateScore
                                      winnerId:winnerId];
        }
    }
}

- (void)pusherPlayDateMemoryRefreshGame:(NSNotification *)notification {
    // Hide winner/loser
    [UIView animateWithDuration:0.4f
                     animations:^{
                         winnerView.alpha = 0.0f;
                         loserView.alpha = 0.0f;
                     }
                     completion:^(BOOL finished) {
                         [winnerView removeFromSuperview];
                         [loserView removeFromSuperview];
                     }];
    
    // Reset all UIViews
    [self removeCards]; // TODO: Make fadeout
    [scoreViewMe setScore:0];
    [scoreViewMe showYourTurn:NO delay:NO];
    [scoreViewOpponent setScore:0];
    [scoreViewOpponent showYourTurn:NO delay:NO];
    
    // Store data
    NSDictionary *eventData = notification.userInfo;
    boardID = [[eventData objectForKey:@"board_id"] integerValue];
    playmateID = [[eventData objectForKey:@"playmate_id"] integerValue];
    initiatorID = [[eventData objectForKey:@"initiator_id"] integerValue];
    numCards = [[eventData objectForKey:@"num_cards"] integerValue];
    isMyTurn = ([PTUser currentUser].userID == initiatorID);
    
    // Store filenames
    NSString *filenamesStr = [eventData valueForKey:@"filename_dump"];
    filenamesStr = [filenamesStr substringWithRange:NSMakeRange(2, [filenamesStr length] - 4)];
    filenames = [filenamesStr componentsSeparatedByString:@"\",\""];
    
    // Blank card indices
    cardIndex1 = nil;
    cardIndex2 = nil;
    
    // Show whose turn
    if ([PTUser currentUser].userID == initiatorID) {
        [scoreViewMe showYourTurn:YES delay:NO];
    } else {
        [scoreViewOpponent showYourTurn:YES delay:NO];
    }
    
    // Set active chat HUD
    [self performSelector:@selector(setActiveChatHUD) withObject:nil afterDelay:1.0f];
    
    // Setup the cards
    [self setupCards];
    
    // Show all cards
    [self showCards];
}

#pragma mark - End playdate methods

- (IBAction)endPlaydateHandle:(id)sender {
    // Notify server of disconnect
    [self disconnectPusherAndChat];
    if (playdate) {
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
    } else {
        // Solo call - disconnect anyway
        [self transitionToDialpad];
        [self.chatController stopPlayingMovies];
    }
}

- (void)disconnectPusherAndChat {
    // Unsubscribe from playdate channel
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (playdate) {
        [[PTPlayTellPusher sharedPusher] unsubscribeFromPlaydateChannel:playdate.pusherChannelName];
    }
#if !(TARGET_IPHONE_SIMULATOR)
    [[PTVideoPhone sharedPhone] disconnect];
#endif
}

- (void)transitionToDialpad {
    PTAppDelegate* appDelegate = (PTAppDelegate*)[[UIApplication sharedApplication] delegate];
    if (appDelegate.dialpadController.loadingView != nil) {
        [appDelegate.dialpadController.loadingView removeFromSuperview];
    }
    [appDelegate.transitionController transitionToViewController:appDelegate.dialpadController
                                                     withOptions:UIViewAnimationOptionTransitionCrossDissolve];
}

#pragma mark - Memory Game delegates

- (BOOL)memoryGameCardShouldFlip:(NSInteger)index {
    // Is it my turn?
    if (isMyTurn == NO) {
        [self showWaitYourTurn];
        return NO;
    }
    
    // Are both cards already flipped?
    if (cardIndex1 != nil && cardIndex2 != nil) {
        return NO;
    }
    
    return YES;
}

- (void)memoryGameCardDidFlip:(NSInteger)index {
    // Flipped card
//    PTMemoryGameCard *card = [self getCardByIndex:index];
    
    // Card 1 or card 2?
    if (cardIndex1 == nil) {
        cardIndex1 = [NSNumber numberWithInteger:index];
    } else if (cardIndex2 == nil) {
        cardIndex2 = [NSNumber numberWithInteger:index];
    } else if (cardIndex1 != nil && cardIndex2 != nil) {
        // Shouldn't happen (cards will be disabled), but just in case
        return;
    }

    // API request to record the turn
    PTMemoryPlayTurnRequest *memoryPlayTurnRequest = [[PTMemoryPlayTurnRequest alloc] init];
    [memoryPlayTurnRequest placePieceAuthToken:[PTUser currentUser].authToken
                                       user_id:[PTUser currentUser].userID
                                      board_id:boardID
                                   playdate_id:playdate.playdateID
                                   card1_index:cardIndex1
                                   card2_index:cardIndex2
                                     onSuccess:^(NSDictionary *result) {
                                         // Get needed data
                                         NSInteger statusCode = [[result objectForKey:@"status"] integerValue];
                                         NSInteger currentPlayerId = [[result objectForKey:@"playmate_id"] integerValue];
                                         NSInteger whoseTurn = [[result objectForKey:@"turn"] integerValue];
                                         
                                         // Now that 2 cards have been flipped, verify next steps
                                         if (cardIndex1 != nil && cardIndex2 != nil) {
                                             NSInteger initiatorScore = [[result objectForKey:@"initiator_score"] integerValue];
                                             NSInteger playmateScore = [[result objectForKey:@"playmate_score"] integerValue];
                                             NSNumber *winnerId = [result objectForKey:@"winner_id"];
                                             [self handleGameTurnWithStatusCode:statusCode
                                                                     playmateId:currentPlayerId
                                                                           turn:whoseTurn
                                                                 initiatorScore:initiatorScore
                                                                  playmateScore:playmateScore
                                                                       winnerId:winnerId];
                                         }
                                     } onFailure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                         NSLog(@"FAIL API: %@", error);
                                         NSLog(@"FAIL API: %@", JSON);
                                         // TODO: How to handle?
                                     }];
}

@end