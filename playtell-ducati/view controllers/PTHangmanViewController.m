//
//  PTHangmanViewController.m
//  playtell-ducati
//
//  Created by Dimitry Bentsionov on 12/12/12.
//  Copyright (c) 2012 PlayTell. All rights reserved.
//

#import "PTHangmanViewController.h"
#import "PTHangmanRefreshGameRequest.h"
#import "PTHangmanEndGameRequest.h"
#import "PTHangmanPlayTurnRequest.h"
#import "PTUser.h"
#import "PTAppDelegate.h"
#import "TransitionController.h"
#import "PTDialpadViewController.h"
#import "PTPlaydateDisconnectRequest.h"
#import "PTHangmanLetterView.h"
#import "UIColor+ColorFromHex.h"
#import "PTHangmanGuessLetterView.h"

@interface PTHangmanViewController ()

@end

#define STATE_NONE        -1 // Playmate is just waiting
#define STATE_WORD_PICK    0 // Initiator is picking a word
#define STATE_LETTER_PICK  1 // Playmate is picking a letter
#define STATE_DRAW         2 // Initiator is drawing
#define STATE_FINISHED     3 // Game finished by win or loss
#define STATE_ENDED        4 // Game ended prematurely by either player

#define TURN_WORD_PICK     0 // Initiator has chosen a word
#define TURN_LETTER_PICK   1 // Playmate has guessed a letter
#define TURN_DRAW          2 // Initiator has drawn a shape
#define TURN_HANG          3 // Initiator has chosen to hang the man

#define WHOSE_TURN_INITIATOR 0
#define WHOSE_TURN_PLAYMATE  1

@implementation PTHangmanViewController

@synthesize chatController;

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil
             playdate:(PTPlaydate *)_playdate
              boardId:(NSInteger)_boardId
            initiator:(PTPlaymate *)_initiator
             playmate:(PTPlaymate *)_playmate {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Save game config
        playdate = _playdate;
        boardId = _boardId;
        initiator = _initiator;
        playmate = _playmate;
        
        // My turn at game start?
        myTurn = [PTUser currentUser].userID == initiator.userID;
        
        // Default game state
        if (myTurn == YES) {
            gameState = STATE_WORD_PICK;
        } else {
            gameState = STATE_NONE;
        }
        
        // Subscribe to Pusher events
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pusherPlayTurn:) name:@"PlayDateHangmanPlayTurn" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pusherEndGame:) name:@"PlayDateHangmanEndGame" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pusherRefreshGame:) name:@"PlayDateHangmanRefreshGame" object:nil];
        
        // Empty word at the start
        wordArray = [NSMutableArray array];
        wordLetterViews = [NSMutableArray array];
        isAnimatingLetters = NO;
        isSelectLetterViewSetup = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Background
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"hangman-bg"]];
    
    // Display chat HUD
    [self.view addSubview:self.chatController.view];
    
    // Setup "end playdate" button
    endPlaydate.layer.shadowColor = [UIColor blackColor].CGColor;
    endPlaydate.layer.shadowOffset = CGSizeMake(0.0f, 2.0f);
    endPlaydate.layer.shadowOpacity = 0.2f;
    endPlaydate.layer.shadowRadius = 6.0f;
    
    // If my turn show word selection, otherwise 'plz wait' dialog
    if (myTurn == YES) {
        viewSelectWord.hidden = NO;
    } else {
        viewWaitForWord.hidden = NO;
    }
    
    // Setup the alphabet scrollview
    letterScrollView.userInteractionEnabled = YES;
    letterScrollView.canCancelContentTouches = NO;
    letterScrollView.delaysContentTouches = YES;
    letterScrollView.showsHorizontalScrollIndicator = NO;
    letterScrollView.showsVerticalScrollIndicator = NO;
    
    // Insert all the letters
    CGSize letterSize = CGSizeMake(100.0f, 150.0f);
    CGFloat spacing = 17.0f;
    CGFloat x = spacing;
    for(char c = 'A'; c <= 'Z'; c++){
        NSString *letter = [NSString stringWithFormat:@"%c", c];
        PTHangmanLetterView *letterView = [[PTHangmanLetterView alloc] initWithFrame:CGRectMake(x, spacing, letterSize.width, letterSize.height) letter:letter];
        letterView.delegate = self;
        letterView.tag = 1;
        [letterScrollView addSubview:letterView];
        x += letterSize.width + spacing;
    }
    [letterScrollView setContentSize:CGSizeMake(x, letterScrollView.bounds.size.height)];
    
    // Add backgrounds & shadows to all board views
    [self setupBoardView:viewSelectWord];
    [self setupBoardView:viewSelectLetter];
    [self setupBoardView:viewDraw];
    [self setupBoardView:viewWaitForWord];
    //[self setupBoardView:viewWaitForLetter];
    [self setupBoardView:viewWaitForDrawing];
    
    // Init gallows
    viewGallows = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hangman-gallows"]];
    viewGallows.hidden = YES;
    viewGallows.alpha = 0.0f;
    viewGallows.frame = CGRectMake(-135.0f, 172.0f, 228.0f, 430.0f);
    [self.view insertSubview:viewGallows atIndex:0];
}

- (void)viewDidAppear:(BOOL)animated {
    // Show the gallows
    viewGallows.hidden = NO;
    [UIView animateWithDuration:0.5f animations:^{
        viewGallows.alpha = 1.0f;
    }];
    
    // Hide the alphabet letters if not our turn
    if (myTurn == NO) {
        [self disableAlphabet];
    }
}

- (void)dealloc {
    // Notifications cleanup
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

#pragma mark - End playdate

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
    // Notifications cleanup
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    PTAppDelegate* appDelegate = (PTAppDelegate*)[[UIApplication sharedApplication] delegate];
    if (appDelegate.dialpadController.loadingView != nil) {
        [appDelegate.dialpadController.loadingView removeFromSuperview];
    }
    [appDelegate.transitionController transitionToViewController:appDelegate.dialpadController
                                                     withOptions:UIViewAnimationOptionTransitionCrossDissolve];
}

#pragma mark - End game

- (IBAction)endGame:(id)sender {
    // API call to end the game
    PTHangmanEndGameRequest *endGameRequest = [[PTHangmanEndGameRequest alloc] init];
    [endGameRequest endGameWithBoardId:boardId
                             authToken:[PTUser currentUser].authToken
                             onSuccess:nil
                             onFailure:nil];
    
    // Notifications cleanup
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    // Transition to playdate view controller
    PTAppDelegate* appDelegate = (PTAppDelegate*)[[UIApplication sharedApplication] delegate];
    [appDelegate.transitionController transitionToViewController:[appDelegate dateViewController] withOptions:UIViewAnimationOptionTransitionCrossDissolve];
}

#pragma mark - Pusher event handlers

- (void)pusherPlayTurn:(NSNotification*)notification {
    NSDictionary *eventData = notification.userInfo;
    NSLog(@"pusherPlayTurn: %@", eventData);
    NSInteger newGameState = [[eventData objectForKey:@"state"] integerValue];
    NSInteger currentPlayerId = [[eventData objectForKey:@"playmate_id"] integerValue];
    NSInteger whoseTurn = [[eventData objectForKey:@"whose_turn"] integerValue];

    // Is it my turn?
    if (whoseTurn == WHOSE_TURN_INITIATOR) {
        myTurn = [PTUser currentUser].userID == initiator.userID;
    } else {
        myTurn = [PTUser currentUser].userID == playmate.userID;
    }

    // Verify that it wasn't us who took this turn
    if (currentPlayerId != [[PTUser currentUser] userID]) {
        // Update game state
        gameState = newGameState;
        switch (gameState) {
            case STATE_LETTER_PICK: {
                // If I'm the game initiator, this state means the playmate guessed their last letter right and are guessing again
                if (initiator.userID == [PTUser currentUser].userID) {
                    // Reveal letter(s) in approprivate letterView(s)
                    NSArray *positions = [eventData objectForKey:@"positions"];
                    if (positions != nil && [positions count] > 0) {
                        NSString *letter = [wordArray objectAtIndex:[[positions objectAtIndex:0] integerValue]];
                        for (int i=0; i<[positions count]; i++) {
                            PTHangmanGuessLetterView *guessLetterView = [guessLetterViews objectAtIndex:[[positions objectAtIndex:i] integerValue]];
                            guessLetterView.letter = letter;
                        }
                    }
                } else {
                    // Otherwise, it's my turn to pick a letter

                    // Check if word length has been passed in
                    // It's passed in as soon as word is chosen by initator
                    NSNumber *wordLengthObj = [eventData objectForKey:@"word_length"];
                    if (wordLengthObj != nil) {
                        wordLength = [wordLengthObj integerValue];
                        NSLog(@"Word length: %d", wordLength);
                    }

                    // Setup letter pick view
                    if (isSelectLetterViewSetup == NO) {
                        [self setupSelectLetterView];
                    }

                    // Switch to letter pick view
                    viewWaitForWord.hidden = YES;
                    viewWaitForDrawing.hidden = YES;
                    viewSelectLetter.hidden = NO;
                    
                    // Fade in the guess letter views
                    [self fadeInGuessLetterViews];
                    
                    // Enable alphabet
                    [self enableAlphabet];
                }
            }
                break;
            case STATE_DRAW: {
                // Switch to drawing view
                //viewWaitForLetter.hidden = YES;
                viewSelectLetter.hidden = YES;
                viewDraw.hidden = NO;
            }
                break;
            case STATE_FINISHED: {
                if (initiator.userID == [PTUser currentUser].userID) {
                    // Reveal letter(s) in approprivate letterView(s)
                    NSArray *positions = [eventData objectForKey:@"positions"];
                    if (positions != nil && [positions count] > 0) {
                        NSString *letter = [wordArray objectAtIndex:[[positions objectAtIndex:0] integerValue]];
                        for (int i=0; i<[positions count]; i++) {
                            PTHangmanGuessLetterView *guessLetterView = [guessLetterViews objectAtIndex:[[positions objectAtIndex:i] integerValue]];
                            guessLetterView.letter = letter;
                        }
                    }
                }
            }
                break;
            case STATE_ENDED:
                break;
        }
    }
}

- (void)pusherEndGame:(NSNotification*)notification {
    NSDictionary *eventData = notification.userInfo;
    NSInteger initiatorId = [[eventData objectForKey:@"playmate_id"] integerValue]; // Who ended the game
    
    if (initiatorId != [[PTUser currentUser] userID]) { // Skip if we are the ones who ended the game
        // Notifications cleanup
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        
        // Transition to playdate view controller
        PTAppDelegate* appDelegate = (PTAppDelegate*)[[UIApplication sharedApplication] delegate];
        [appDelegate.transitionController transitionToViewController:[appDelegate dateViewController] withOptions:UIViewAnimationOptionTransitionCrossDissolve];
    }
}

- (void)pusherRefreshGame:(NSNotification*)notification {
//    NSDictionary *eventData = notification.userInfo;
//    
//    // Get response parameters
//    NSInteger initiatorId = [[eventData objectForKey:@"initiator_id"] integerValue];
//    NSInteger _boardId = [[eventData objectForKey:@"board_id"] integerValue];
//    NSInteger _totalCards = [[eventData objectForKey:@"num_cards"] integerValue];
//    NSString *filenamesFlat = [eventData valueForKey:@"filename_dump"];
//    filenamesFlat = [filenamesFlat substringWithRange:NSMakeRange(2, [filenamesFlat length] - 4)];
//    NSArray *_filenames = [filenamesFlat componentsSeparatedByString:@"\",\""];
//    NSString *cardsString = [eventData valueForKey:@"card_array_string"];
//    
//    PTPlaymate *aInitiator;
//    PTPlaymate *aPlaymate;
//    if (playdate.initiator.userID == initiatorId) {
//        aInitiator = playdate.initiator;
//        aPlaymate = playdate.playmate;
//    } else {
//        aInitiator = playdate.playmate;
//        aPlaymate = playdate.initiator;
//    }
//    
//    // My turn?
//    BOOL isMyTurn = [PTUser currentUser].userID == initiatorId;
//    
//    // Init the math game controller
//    PTMathViewController *mathViewController = [[PTMathViewController alloc]
//                                                initWithNibName:@"PTMathViewController"
//                                                bundle:nil
//                                                playdate:playdate
//                                                boardId:_boardId
//                                                themeId:2 // TODO: Hard coded
//                                                initiator:aInitiator
//                                                playmate:aPlaymate
//                                                filenames:_filenames
//                                                totalCards:_totalCards
//                                                cardsString:cardsString
//                                                myTurn:isMyTurn];
//    mathViewController.chatController = self.chatController;
//    
//    // Init game splash
//    UIImageView *splash =  [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 1024.0f, 768.0f)];
//    splash.image = [UIImage imageNamed:@"math-splash"];
//    
//    // Notifications cleanup
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
//    
//    // Bring up the view controller of the new game
//    PTAppDelegate* appDelegate = (PTAppDelegate*)[[UIApplication sharedApplication] delegate];
//    [appDelegate.transitionController loadGame:mathViewController
//                                   withOptions:UIViewAnimationOptionTransitionCurlUp
//                                    withSplash:splash];
}

- (void)viewDidUnload {
    viewSelectWord = nil;
    [super viewDidUnload];
}

#pragma mark - Game methods

- (IBAction)selectWord:(id)sender {
    // Is the word empty?
    if ([wordArray count] == 0) {
        return;
    }
    
    // Convert word array to string and lowercase it
    NSString *word = [[wordArray componentsJoinedByString:@""] lowercaseString];
    wordLength = [wordArray count];
    
    // Disable alphabet
    [self disableAlphabet];
    
    // API call to submit the word
    PTHangmanPlayTurnRequest *apiRequest = [[PTHangmanPlayTurnRequest alloc] init];
    [apiRequest pickWordForBoardId:boardId
                              word:word
                         authToken:[PTUser currentUser].authToken
                         onSuccess:^(NSDictionary *result) {
                             NSLog(@"pickWordForBoardId: %@", result);
                             // Setup letter pick view
                             if (isSelectLetterViewSetup == NO) {
                                 [self setupSelectLetterView];
                             }
                             
                             // Switch to letter pick view
                             viewSelectWord.hidden = YES;
                             //viewWaitForLetter.hidden = NO;
                             viewSelectLetter.hidden = NO;
                             
                             // Fade in the guess letter views
                             [self fadeInGuessLetterViews];
                         }
                         onFailure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                             NSLog(@"pickWordForBoardId fail: %@", error);
                             NSLog(@"pickWordForBoardId fail: %@", JSON);
                         }];
}

- (void)selectLetter:(NSString*)letter {
    PTHangmanPlayTurnRequest *apiRequest = [[PTHangmanPlayTurnRequest alloc] init];
    [apiRequest guessLetterForBoardId:boardId
                               letter:letter
                            authToken:[PTUser currentUser].authToken
                            onSuccess:^(NSDictionary *result) {
                                NSInteger newGameState = [[result objectForKey:@"state"] integerValue];
                                
                                // Did we guess correctly?
                                if (newGameState == STATE_DRAW) {
                                    // No, we missed the letter
                                    
                                    // Disable the alphabet
                                    [self disableAlphabet];
                                    
                                    // Show 'waiting for drawing' screen
                                    viewSelectLetter.hidden = YES;
                                    viewWaitForDrawing.hidden = NO;
                                    
                                    // Enable the alphabet again (for future)
                                    isAnimatingLetters = NO;
                                } else {
                                    // Yes! We guessed it right
                                    // Reveal letter(s) in approprivate letterView(s)
                                    NSArray *positions = [result objectForKey:@"positions"];
                                    for (int i=0; i<[positions count]; i++) {
                                        PTHangmanGuessLetterView *guessLetterView = [guessLetterViews objectAtIndex:[[positions objectAtIndex:i] integerValue]];
                                        guessLetterView.letter = letter;
                                    }
                                    
                                    // Enable the alphabet again
                                    isAnimatingLetters = NO;
                                    letterScrollView.userInteractionEnabled = YES;
                                    letterScrollView.alpha = 1.0f;
                                }
                            }
                            onFailure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                NSLog(@"guessLetterForBoardId fail: %@", error);
                                NSLog(@"guessLetterForBoardId fail: %@", JSON);
                            }];
}

- (IBAction)submitDrawing:(id)sender {
    PTHangmanPlayTurnRequest *apiRequest = [[PTHangmanPlayTurnRequest alloc] init];
    [apiRequest drawShapeOnBoardId:boardId
                         authToken:[PTUser currentUser].authToken
                         onSuccess:^(NSDictionary *result) {
                             // Show 'waiting for letter' screen
                             viewDraw.hidden = YES;
                             //viewWaitForLetter.hidden = NO;
                             viewSelectLetter.hidden = NO;
                         }
                         onFailure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                             NSLog(@"drawShapeOnBoardId fail: %@", error);
                             NSLog(@"drawShapeOnBoardId fail: %@", JSON);
                         }];
}

#pragma mark - Handman delegate

- (void)letterViewDidPress:(PTHangmanLetterView *)letterView letter:(NSString *)letter {
    // Precautionary
    if (isAnimatingLetters == YES || myTurn == NO) {
        return;
    }
    isAnimatingLetters = YES;

    // We are selecting a letter
    if (gameState == STATE_LETTER_PICK) {
        // While the call is being made, briefly disable the alphabet
        letterScrollView.userInteractionEnabled = NO;
        letterScrollView.alpha = 0.8f;
        
        // API call to guess the letter
        [self selectLetter:letter];
        return;
    }
    
    // We are selecting a word
    if (gameState == STATE_WORD_PICK) {
        // Check if we're adding or removing the letter (tag 1: adding, tag 2: removing)
        if (letterView.tag == 1) {
            if ([wordArray count] == 6) {
                // We hit our max, do something
                isAnimatingLetters = NO;
                return;
            }
            
            // Add new letter to array
            [wordArray addObject:letter];
            
            // Create a new letter object
            PTHangmanLetterView *newLetterView = [[PTHangmanLetterView alloc] initWithFrame:letterView.bounds letter:letter];
            newLetterView.delegate = self;
            newLetterView.tag = 2; // Tag 2 = next time its tapped, its removed
            [wordLetterViews addObject:newLetterView];
            
            // Find new positions for all letters
            CGFloat totalLettersWidth = 0.0f;
            CGFloat spacer = 20.0f;
            PTHangmanLetterView *currentLetterView;
            for (int i=0; i<[wordLetterViews count]; i++) {
                currentLetterView = (PTHangmanLetterView *)[wordLetterViews objectAtIndex:i];
                totalLettersWidth += currentLetterView.bounds.size.width + spacer;
            }
            totalLettersWidth -= spacer; // Remove the trailing spacer
            CGFloat leftOffset = (viewSelectWord.bounds.size.width - totalLettersWidth) / 2.0f;
            CGFloat topOffset = (viewSelectWord.bounds.size.height - currentLetterView.bounds.size.height) / 2.0f;
            
            // Set position for last letter (one just added)
            currentLetterView.frame = CGRectMake((leftOffset + totalLettersWidth - currentLetterView.bounds.size.width), topOffset, currentLetterView.bounds.size.width, currentLetterView.bounds.size.height);
            currentLetterView.alpha = 0.0f;
            [viewSelectWord addSubview:currentLetterView];
            
            // Animate all letters
            if ([wordLetterViews count] > 1) {
                // First move all previous letters
                [UIView animateWithDuration:0.15f
                                 animations:^{
                                     CGFloat x = leftOffset;
                                     PTHangmanLetterView *letterView;
                                     for (int i=0; i<[wordLetterViews count]; i++) {
                                         letterView = (PTHangmanLetterView *)[wordLetterViews objectAtIndex:i];
                                         letterView.frame = CGRectMake(x, topOffset, letterView.bounds.size.width, letterView.bounds.size.height);
                                         x += letterView.bounds.size.width + spacer;
                                     }
                                 }
                                 completion:^(BOOL finished) {
                                     [UIView animateWithDuration:0.15f
                                                      animations:^{
                                                          // Fade in the last letter (newest one)
                                                          PTHangmanLetterView *letterView = (PTHangmanLetterView *)[wordLetterViews objectAtIndex:([wordLetterViews count] - 1)];
                                                          letterView.alpha = 1.0f;
                                                      }
                                                      completion:^(BOOL finished) {
                                                          isAnimatingLetters = NO;
                                                      }];
                                 }];
            } else {
                // If first one, place it and fade it in
                [UIView animateWithDuration:0.15f
                                 animations:^{
                                     currentLetterView.alpha = 1.0f;
                                 }
                                 completion:^(BOOL finished) {
                                     isAnimatingLetters = NO;
                                 }];
            }
        } else {
            // Remove this letter from array
            for (int i=0; i<[wordArray count]; i++) {
                if ([letter isEqualToString:[wordArray objectAtIndex:i]]) {
                    [wordArray removeObjectAtIndex:i];
                    [wordLetterViews removeObjectAtIndex:i];
                    break;
                }
            }
            
            // Find out new locations for all leftover letters
            if ([wordArray count] == 0) {
                // Fade out the one we just removed and call it a day
                [UIView animateWithDuration:0.15f
                                 animations:^{
                                     letterView.alpha = 0.0f;
                                 } completion:^(BOOL finished) {
                                     [letterView removeFromSuperview];
                                     isAnimatingLetters = NO;
                                 }];
                return;
            }
            
            // Find new positions for all letters
            CGFloat totalLettersWidth = 0.0f;
            CGFloat spacer = 20.0f;
            PTHangmanLetterView *currentLetterView;
            for (int i=0; i<[wordLetterViews count]; i++) {
                currentLetterView = (PTHangmanLetterView *)[wordLetterViews objectAtIndex:i];
                totalLettersWidth += currentLetterView.bounds.size.width + spacer;
            }
            totalLettersWidth -= spacer; // Remove the trailing spacer
            CGFloat leftOffset = (viewSelectWord.bounds.size.width - totalLettersWidth) / 2.0f;
            CGFloat topOffset = (viewSelectWord.bounds.size.height - currentLetterView.bounds.size.height) / 2.0f;
            
            // Fade out the one we just removed, the move all remaining ones
            [UIView animateWithDuration:0.15f
                             animations:^{
                                 letterView.alpha = 0.0f;
                             } completion:^(BOOL finished) {
                                 // Remove from container
                                 [letterView removeFromSuperview];
                                 
                                 // Move all others
                                 [UIView animateWithDuration:0.15f
                                                  animations:^{
                                                      CGFloat x = leftOffset;
                                                      PTHangmanLetterView *letterView;
                                                      for (int i=0; i<[wordLetterViews count]; i++) {
                                                          letterView = (PTHangmanLetterView *)[wordLetterViews objectAtIndex:i];
                                                          letterView.frame = CGRectMake(x, topOffset, letterView.bounds.size.width, letterView.bounds.size.height);
                                                          x += letterView.bounds.size.width + spacer;
                                                      }
                                                  }
                                                  completion:^(BOOL finished) {
                                                      isAnimatingLetters = NO;
                                                  }];
                             }];
        }
        return;
    }
}

#pragma mark - UI methods

- (void)setupBoardView:(UIView*)view {
    view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"hangman-wordboard"]];

    [view.layer setMasksToBounds:NO];
    [view.layer setShadowColor:[UIColor colorFromHex:@"#405b59"].CGColor];
    [view.layer setShadowOpacity:0.3];
    [view.layer setShadowRadius:6.0];
    [view.layer setShadowOffset:CGSizeMake(0, 0)];
    [view.layer setShouldRasterize:YES];
    
    UIBezierPath * depthShadowPath = [UIBezierPath bezierPath];
    [depthShadowPath moveToPoint:CGPointMake(235, 235)];
    [depthShadowPath addLineToPoint:CGPointMake(view.frame.size.width - 235, 235)];
    [depthShadowPath addLineToPoint:CGPointMake(view.frame.size.width - 50, view.frame.size.height + 30)];
    [depthShadowPath addLineToPoint:CGPointMake(50, view.frame.size.height + 30)];
    [depthShadowPath addLineToPoint:CGPointMake(235, 235)];
    [view.layer setShadowPath:depthShadowPath.CGPath];
}

- (void)setupSelectLetterView {
    isSelectLetterViewSetup = YES;

    // Create the guess letter views
    guessLetterViews = [NSMutableArray arrayWithCapacity:wordLength];
    
    CGFloat spacer = 20.0f;
    CGSize letterViewSize = CGSizeMake(100.0f, 150.0f);
    CGFloat totalLettersWidth = (letterViewSize.width * wordLength) + (spacer * (wordLength - 1));
    CGFloat leftOffset = (viewSelectLetter.bounds.size.width - totalLettersWidth) / 2.0f;
    CGFloat topOffset = (viewSelectLetter.bounds.size.height - letterViewSize.height) / 2.0f;
    
    CGFloat x = leftOffset;
    for (int i=0; i<wordLength; i++) {
        CGRect frame = CGRectMake(x, topOffset, letterViewSize.width, letterViewSize.height);
        PTHangmanGuessLetterView *guessLetterView = [[PTHangmanGuessLetterView alloc] initWithFrame:frame];
        guessLetterView.alpha = 0.0f;
        [viewSelectLetter addSubview:guessLetterView];
        [guessLetterViews addObject:guessLetterView];
        x += letterViewSize.width + spacer;
    }
}

- (void)fadeInGuessLetterViews {
    // Already faded in?
    PTHangmanGuessLetterView *guessLetterView = [guessLetterViews objectAtIndex:0];
    if (guessLetterView.alpha == 1.0f) {
        return;
    }

    [UIView animateWithDuration:0.5f
                     animations:^{
                         for (int i=0; i<[guessLetterViews count]; i++) {
                             PTHangmanGuessLetterView *guessLetterView = (PTHangmanGuessLetterView *)[guessLetterViews objectAtIndex:i];
                             guessLetterView.alpha = 1.0f;
                         }
                     }];
}

- (void)disableAlphabet {
    // Hide the alphabet letters if not our turn
    letterScrollView.userInteractionEnabled = NO;
    [UIView animateWithDuration:0.5f animations:^{
        letterScrollView.frame = CGRectOffset(letterScrollView.frame, 0.0f, 90.0f);
        letterScrollView.alpha = 0.5f;
    }];
}

- (void)enableAlphabet {
    // Show the alphabet letters if not our turn
    [UIView animateWithDuration:0.5f animations:^{
        letterScrollView.frame = CGRectOffset(letterScrollView.frame, 0.0f, -90.0f);
        letterScrollView.alpha = 1.0f;
    } completion:^(BOOL finished) {
        letterScrollView.userInteractionEnabled = YES;
    }];
}

@end