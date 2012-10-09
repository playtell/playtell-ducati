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
    
    // Add cards to board
    cards = [NSMutableArray arrayWithCapacity:[filenames count]];
    for (int i=0; i<[filenames count]; i++) {
        PTMemoryGameCard *card = [[PTMemoryGameCard alloc] initWithFrontFilename:[filenames objectAtIndex:i]
                                                                    backFilename:@"card-back.png"
                                                                    indexOnBoard:i
                                                                   numberOfCards:numCards];
        [card.card setFrame:CGRectMake(card.coordinates.boardX,
                                       card.coordinates.boardY,
                                       card.size.width,
                                       card.size.height)];
        card.card.hidden = YES;
        card.card.alpha = 0.0f;
        card.delegate = self;
        [self.view addSubview:card.card];
        [cards addObject:card];
    }

    // Display chat HUD?
#if !(TARGET_IPHONE_SIMULATOR)
    [self.view addSubview:self.chatController.view];
#endif
    
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
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)viewDidAppear:(BOOL)animated {
    // Show all cards
    for (PTMemoryGameCard *card in cards) {
        card.card.hidden = NO;
    }
    [UIView animateWithDuration:0.4f animations:^{
        for (PTMemoryGameCard *card in cards) {
            card.card.hidden = NO;
            card.card.alpha = 1.0f;
        }
    }];
}

- (void)dealloc {
    // Notifications cleanup
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

#pragma mark - Card methods

- (PTMemoryGameCard *)getCardByIndex:(NSInteger)index {
    if (index < [cards count]) {
        return (PTMemoryGameCard *)[cards objectAtIndex:index];
    }
    return nil;
}

- (void)disableCards {
    for (PTMemoryGameCard *card in cards) {
        card.card.enabled = NO;
    }
}

- (void)enableCards {
    for (PTMemoryGameCard *card in cards) {
        card.card.enabled = YES;
    }
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
    NSURL *win = [[NSBundle mainBundle] URLForResource:@"winner-applause" withExtension:@"wav"];
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

- (void)displayYouLost {
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

- (void)handleGameTurnWithStatusCode:(NSInteger)statusCode
                          playmateId:(NSInteger)currentPlayerId
                                turn:(NSInteger)whoseTurn {
//#define MATCH_FOUND 0
//#define MATCH_ERROR 1
//#define FLIP_FIRST_CARD 2
//#define MATCH_WINNER 3

    NSLog(@"Status code: %i", statusCode);
    switch (statusCode) {
        // Match found!
        case MATCH_FOUND: {
            NSLog(@"Match found! Disabling cards. Updating score. Same user can continue.");
            // TODO: Disable both cards (aka. take them out of the game)

            // Reset card indices
            cardIndex1 = nil;
            cardIndex2 = nil;

            // TODO: Update score
            // TODO: Keep the user the same
            break;
        }
        
        // Cards do not match
        case MATCH_ERROR: {
            NSLog(@"Cards not matched. Flipping them back. Switching turn.");
            // Flip both cards back
            PTMemoryGameCard *card1 = (PTMemoryGameCard *)[cards objectAtIndex:[cardIndex1 integerValue]];
            PTMemoryGameCard *card2 = (PTMemoryGameCard *)[cards objectAtIndex:[cardIndex2 integerValue]];
            [card1 flipCardDelayed:YES];
            [card2 flipCardDelayed:YES];
            
            // Reset card indices
            cardIndex1 = nil;
            cardIndex2 = nil;
            
            // Switch whose turn it is
            isMyTurn = !isMyTurn;
            // TODO: Visually let person know it's their turn now
            if (isMyTurn == YES) {
                // ...
            }
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
            // TODO: Show winner/loser views
            // TODO: Update scores
            // TODO: Start new game after timeout?
            NSLog(@"Match won!");
            break;
        }
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
    NSLog(@"pusherPlayDateMemoryPlayTurn: %@", eventData);
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
            [self handleGameTurnWithStatusCode:statusCode
                                    playmateId:currentPlayerId
                                          turn:whoseTurn];
        }
    }
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
                                         NSLog(@"Success API: %@", result);

                                         // Get needed data
                                         NSInteger statusCode = [[result objectForKey:@"status"] integerValue];
                                         NSInteger currentPlayerId = [[result objectForKey:@"playmate_id"] integerValue];
                                         NSInteger whoseTurn = [[result objectForKey:@"turn"] integerValue];
                                         
                                         // Now that 2 cards have been flipped, verify next steps
                                         if (cardIndex1 != nil && cardIndex2 != nil) {
                                             [self handleGameTurnWithStatusCode:statusCode
                                                                     playmateId:currentPlayerId
                                                                           turn:whoseTurn];
                                         }
                                     } onFailure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                         NSLog(@"FAIL API: %@", error);
                                         NSLog(@"FAIL API: %@", JSON);
                                         // TODO: How to handle?
                                     }];
}

@end