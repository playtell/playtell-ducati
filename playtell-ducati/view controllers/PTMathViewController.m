//
//  PTMathViewController.m
//  playtell-ducati
//
//  Created by Dimitry Bentsionov on 11/8/12.
//  Copyright (c) 2012 PlayTell. All rights reserved.
//

#import "PTMathViewController.h"
#import "PTMatchingEndGameRequest.h"
#import "PTMatchingPlayTurnRequest.h"
#import "PTMatchingRefreshGameRequest.h"
#import "PTUser.h"
#import "PTAppDelegate.h"
#import "TransitionController.h"
#import "PTDialpadViewController.h"
#import "PTPlaydateDisconnectRequest.h"
#import "PTMatchingPairingCardView.h"

@interface PTMathViewController ()

@end

@implementation PTMathViewController

- (id)initWithNibName:(NSString*)nibNameOrNil
               bundle:(NSBundle*)nibBundleOrNil
             playdate:(PTPlaydate*)_playdate
              boardId:(NSInteger)_boardId
              themeId:(NSInteger)_themeId
            initiator:(PTPlaymate *)_initiator
             playmate:(PTPlaymate *)_playmate
            filenames:(NSArray*)_filenames
           totalCards:(NSInteger)_totalCards
          cardsString:(NSString*)_cardsString
               myTurn:(BOOL)_myTurn {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Save game config
        playdate = _playdate;
        boardId = _boardId;
        themeId = _themeId;
        initiator = _initiator;
        playmate = _playmate;
        filenames = _filenames;
        totalCards = (_totalCards/2.0f); // Really there are twice as many, but they're all halves
        myTurn = _myTurn;
        isGameOver = NO;
        
        // Parse cards string
        NSArray *stringArr = [_cardsString componentsSeparatedByString:@","];
        availableCards = [NSArray arrayWithArray:[stringArr subarrayWithRange:NSMakeRange(0, totalCards)]];
        pairingCards = [NSArray arrayWithArray:[stringArr subarrayWithRange:NSMakeRange(totalCards, totalCards)]];
        
        // Subscribe to Pusher events
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pusherPlayTurn:) name:@"PlayDateMatchingPlayTurn" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pusherEndGame:) name:@"PlayDateMatchingEndGame" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pusherRefreshGame:) name:@"PlayDateMatchingRefreshGame" object:nil];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Game background
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"math-bg"]];
    
    // Setup "end playdate" button
    endPlaydate.layer.shadowColor = [UIColor blackColor].CGColor;
    endPlaydate.layer.shadowOffset = CGSizeMake(0.0f, 2.0f);
    endPlaydate.layer.shadowOpacity = 0.2f;
    endPlaydate.layer.shadowRadius = 6.0f;
    
    // Setup available cards container
    viewAvailableCards = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 768.0f-224.0f, 1024.0f, 224.0f)];
    viewAvailableCards.hidden = YES;
    viewAvailableCards.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"game-drawer.png"]];
    [self.view addSubview:viewAvailableCards];
    viewAvailableCardsScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 1024.0f, 224.0f)];
    viewAvailableCardsScroll.tag = 1;
    viewAvailableCardsScroll.userInteractionEnabled = YES;
    viewAvailableCardsScroll.canCancelContentTouches = NO;
    viewAvailableCardsScroll.delaysContentTouches = NO;
    viewAvailableCardsScroll.showsHorizontalScrollIndicator = NO;
    viewAvailableCardsScroll.showsVerticalScrollIndicator = NO;
    [viewAvailableCards addSubview:viewAvailableCardsScroll];
    
    // Setup available cards
    [self setupAvailableCards];
    
    // Setup pairing cards container
    viewPairingCardsContainer = [[UIView alloc] initWithFrame:CGRectMake(132.0f, 200.0f, 760.0f, 284.0f)];
    viewPairingCards = [[UIView alloc] initWithFrame:viewPairingCardsContainer.bounds];
    viewPairingCards.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"math-flipboard-front"]];
    viewPairingCards.clipsToBounds = YES;
    [viewPairingCardsContainer addSubview:viewPairingCards];
    [self.view addSubview:viewPairingCardsContainer];
    
    // Setup the initial pairing card
    [self setupInitialPairingCard];
    
    // Set active chat HUD
    [self performSelector:@selector(setActiveChatHUD) withObject:nil afterDelay:0.5f];
    
    // Winner/loser views
    winnerView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 465.0f, 394.0f)];
    winnerView.backgroundColor = [UIColor clearColor];
    winnerView.center = self.view.center;
    winnerView.image = [UIImage imageNamed:@"memory-win"];
    winnerView.alpha = 0.0f;
    loserView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 465.0f, 394.0f)];
    loserView.backgroundColor = [UIColor clearColor];
    loserView.center = self.view.center;
    loserView.image = [UIImage imageNamed:@"memory-win"]; // Everybody wins!
    loserView.alpha = 0.0f;
    drawView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 465.0f, 394.0f)];
    drawView.backgroundColor = [UIColor clearColor];
    drawView.center = self.view.center;
    drawView.image = [UIImage imageNamed:@"memory-win"]; // Everybody wins!
    drawView.alpha = 0.0f;
    
    // Score views
    scoreViewMe = [[PTMatchingScoreView alloc] initWithFrame:CGRectMake(934.0f, 88.0f, 56.0f, 75.0f) myScore:YES];
    [self.view addSubview:scoreViewMe];
    scoreViewOpponent = [[PTMatchingScoreView alloc] initWithFrame:CGRectMake(36.0f, 88.0f, 56.0f, 75.0f) myScore:NO];
    [self.view addSubview:scoreViewOpponent];
    
    // Bottom shadow (when available cards are disabled)
    viewBottomShawdow = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 733.0f, 1024.0f, 35.0f)];
    viewBottomShawdow.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"matching-bottom-shadow"]];
    viewBottomShawdow.alpha = 0;
    [self.view insertSubview:viewBottomShawdow aboveSubview:viewAvailableCards];
    
    // Display chat HUD
    [self.view addSubview:self.chatController.view];
    
    // If not my turn, flip the game board
    if (myTurn == NO) {
        [self performSelector:@selector(flipGameBoard) withObject:nil afterDelay:0.8f];
        [self disableAvailableCards];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    // Notifications cleanup
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

- (void)setupInitialPairingCard {
    // Setup landing zone location
    rectLandingStrip = CGRectMake(483.0f, 254.0f, 283.0f, 178.0f);

    // Set the first card as the "current index"
    currentPairingIndex = totalCards;
    viewCurrentPairingCardView = [[PTMathPairingCardView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 553.0f, 235.0f) cardIndex:currentPairingIndex delegate:self];
    viewCurrentPairingCardView.frame = CGRectMake((viewPairingCards.bounds.size.width-viewCurrentPairingCardView.bounds.size.width)/2.0f + viewPairingCards.bounds.size.width, (viewPairingCards.bounds.size.height-viewCurrentPairingCardView.bounds.size.height)/2.0f, viewCurrentPairingCardView.bounds.size.width, viewCurrentPairingCardView.bounds.size.height); // Move it temporarily off-screen
    viewCurrentPairingCardView.alpha = 0.0f;
    
    // Add it to pairing cards container
    [viewPairingCards addSubview:viewCurrentPairingCardView];
    
    // Slide the pairing card info view
    [self performSelector:@selector(animateCurrentPairingCardIntoView) withObject:nil afterDelay:1.0f];
}

- (void)setupAvailableCards {
    CGFloat x = 25.0f;
    CGFloat maxHeight = 0;
    for (int i=0; i<totalCards; i++) {
        NSInteger cardIndex = i;
        UIImage *cardImage = [self mathGameImageForCardIndex:cardIndex];
        CGSize sizeCard = cardImage.size;
        
        // Calculate max height of cards
        if (sizeCard.height > maxHeight) {
            maxHeight = sizeCard.height;
        }
        
        PTMathAvailableCardView *viewCard = [[PTMathAvailableCardView alloc] initWithFrame:CGRectMake(x, 0.0f, sizeCard.width, sizeCard.height) cardIndex:cardIndex delegate:self];
        [viewCard setCardImage:cardImage];
        [viewAvailableCardsScroll addSubview:viewCard];
        x += sizeCard.width + 25.0f; // + 25 px spacer
    }
    
    // Set scroll view frame size and content size
    CGFloat width = x;
    viewAvailableCards.frame = CGRectMake(0.0f, 768.0f-224.0f, 1024.0f, 224.0f);
    viewAvailableCardsScroll.frame = CGRectMake(0.0f, 0.0f, 1024.0f, 224.0f);
    [viewAvailableCardsScroll setContentSize:CGSizeMake(width, maxHeight)];
    
    // Center (vertically) each available card
    for (PTMathAvailableCardView *viewCard in viewAvailableCardsScroll.subviews) {
        viewCard.frame = CGRectMake(viewCard.frame.origin.x, 50.0f + (maxHeight - viewCard.frame.size.height) / 2.0f, viewCard.frame.size.width, viewCard.frame.size.height);
    }
    
    // Show the available cards container
    [self performSelector:@selector(animateAvailableCardsContainerIntoView) withObject:nil afterDelay:0.5f];
    
    // Save new height for future uses
    heightAvailableCards = maxHeight;
}

- (void)animateCurrentPairingCardIntoView {
    [UIView animateWithDuration:0.5f
                     animations:^{
                         viewCurrentPairingCardView.frame = CGRectOffset(viewCurrentPairingCardView.frame, -viewPairingCards.bounds.size.width, 0.0f);
                         
                         // Don't fade pairing card all the way in if not my turn
                         if (myTurn == YES) {
                             viewCurrentPairingCardView.alpha = 1.0f;
                         } else {
                             viewCurrentPairingCardView.alpha = 0.5f;
                         }
                     }];
}

- (void)animateAvailableCardsContainerIntoView {
    viewAvailableCards.alpha = 0.0f;
    viewAvailableCards.hidden = NO;
    [UIView animateWithDuration:0.3f
                     animations:^{
                         viewAvailableCards.alpha = 1.0f;
                     }];
}

#pragma mark - Game actions

- (IBAction)endGame:(id)sender {
    // API call to end the game
    PTMatchingEndGameRequest *endGameRequest = [[PTMatchingEndGameRequest alloc] init];
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

#pragma mark - End playdate methods

- (IBAction)endPlaydateHandle:(id)sender {
    NSLog(@"endPlaydateHandle");
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
             NSLog(@"PTPlaydateDisconnectRequest: success");
             [self transitionToDialpad];
         }
                                                          onFailure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
         {
             NSLog(@"PTPlaydateDisconnectRequest: failure: %@", error);
             [self transitionToDialpad];
         }];
    }
}

- (void)disconnectPusherAndChat {
    NSLog(@"disconnectPusherAndChat");
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

#pragma mark - Cards scroll delegates

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.tag == 1) { // Available cards scroll view
        //        // Adjust size/opacity of each child as they scroll
        //        CGFloat x = scrollView.contentOffset.x;
        //        CGFloat width = scrollView.frame.size.width;
        //        for (int i=0; i<totalCards; i++) {
        //            CGFloat pos = ABS(i * width - x);
        //            CGFloat level = 1.0f - pos / width;
        //            [(PTMatchingAvailableCardView *)[scrollView.subviews objectAtIndex:i] setFocusLevel:level];
        //        }
    } else if (scrollView.tag == 2) { // Pairing cards scroll view
        // Adjust size/opacity of each child as they scroll
        CGFloat x = scrollView.contentOffset.x;
        CGFloat width = scrollView.frame.size.width;
        for (int i=0; i<totalCards; i++) {
            CGFloat pos = ABS(i * width - x);
            CGFloat level = 1.0f - pos / width;
            NSInteger subviewIndex;
            if (isBoardFlipped == YES) {
                subviewIndex = (totalCards - i - 1);
            } else {
                subviewIndex = i;
            }
            [(PTMatchingPairingCardView *)[scrollView.subviews objectAtIndex:subviewIndex] setFocusLevel:level];
        }
    }
}

#pragma mark - Mathing game delegates

- (void)mathGameAvailableCardTouchesBegan:(PTMathAvailableCardView *)cardView touch:(UITouch *)touch {
    if (viewAvailableCardsScroll.scrollEnabled == NO) {
        return;
    }
    
    // Figure out the points on the screen relative to the touch
    sizeTouchOriginal = cardView.bounds.size;
    pointTouchOriginal = [touch locationInView:self.view];
    pointTouchOffset = [touch locationInView:cardView];
    viewTrackingCard = [[UIView alloc] initWithFrame:CGRectMake(pointTouchOriginal.x - pointTouchOffset.x, pointTouchOriginal.y - pointTouchOffset.y, cardView.bounds.size.width, cardView.bounds.size.height)];
    viewTrackingCard.backgroundColor = [UIColor clearColor];
    viewTrackingCardImage = [[UIImageView alloc] initWithFrame:viewTrackingCard.bounds];
    viewTrackingCardImage.image = [cardView getCardImage];
    viewTrackingCardImage.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [viewTrackingCard addSubview:viewTrackingCardImage];
    [self.view insertSubview:viewTrackingCard belowSubview:self.chatController.view];
    
    // Defaults
    canTrackingCardLand = NO;
    isTrackingCardSmall = YES;
    
    // Save currently selected views
    currentAvailableIndex = [cardView getCardIndex];
    viewCurrentAvailableCardView = cardView;
    
    // Hide the available card
    viewCurrentAvailableCardView.alpha = 0.0f;
}

- (void)mathGameAvailableCardTouchesMoved:(PTMathAvailableCardView *)cardView touch:(UITouch *)touch {
    if (viewAvailableCardsScroll.scrollEnabled == NO) {
        return;
    }
    
    // See if this point is near the landing box
    CGPoint point = [touch locationInView:self.view];
    
    // Get all 4 points of the card
    CGPoint pointTopLeft = CGPointMake(point.x - pointTouchOffset.x, point.y - pointTouchOffset.y);
    CGPoint pointTopRight = CGPointMake(pointTopLeft.x + viewTrackingCard.frame.size.width, pointTopLeft.y);
    CGPoint pointBottomRight = CGPointMake(pointTopLeft.x + viewTrackingCard.frame.size.width, pointTopLeft.y + viewTrackingCard.frame.size.height);
    CGPoint pointBottomLeft = CGPointMake(pointTopLeft.x, pointTopLeft.y + viewTrackingCard.frame.size.height);
    
    // Figure out if card can land
    canTrackingCardLand = CGRectContainsPoint(rectLandingStrip, pointTopLeft) || CGRectContainsPoint(rectLandingStrip, pointBottomRight) || CGRectContainsPoint(rectLandingStrip, pointTopRight) || CGRectContainsPoint(rectLandingStrip, pointBottomLeft);
    
    // Move the tracking card
    viewTrackingCard.frame = CGRectMake(point.x - pointTouchOffset.x, point.y - pointTouchOffset.y, viewTrackingCard.bounds.size.width, viewTrackingCard.bounds.size.height);
    
    // Can the card land?
    if (canTrackingCardLand) {
        [viewCurrentPairingCardView setLandingZoneAsActive];
    } else {
        [viewCurrentPairingCardView setLandingZoneAsInactive];
    }
}

- (void)mathGameAvailableCardTouchesEnded:(PTMathAvailableCardView *)cardView touch:(UITouch *)touch {
    if (viewAvailableCardsScroll.scrollEnabled == NO) {
        return;
    }
    
    // Can we land?
    if (canTrackingCardLand == YES) {
        // Move it to its resting spot next to the right card
        CGFloat x = rectLandingStrip.origin.x + (rectLandingStrip.size.width / 2.0f);
        CGFloat y = rectLandingStrip.origin.y + (rectLandingStrip.size.height / 2.0f);
        [UIView animateWithDuration:0.2f
                         animations:^{
                             viewTrackingCard.center = CGPointMake(x, y);
                         }
                         completion:^(BOOL finished) {
                             // API call to play turn
                             [self playTurn];
                         }];
        
        // Disable highlight state of current pairing card's landing zone
        [viewCurrentPairingCardView setLandingZoneAsInactive];
    } else {
        // If not near landing box, go back to its original location
        [self returnTrackingCardToOriginalLocation];
    }
}

- (void)mathGameAvailableCardTouchesCancelled:(PTMathAvailableCardView *)cardView touch:(UITouch *)touch {
    if (viewAvailableCardsScroll.scrollEnabled == NO) {
        return;
    }
    
    // Show original card
    viewCurrentAvailableCardView.alpha = 1.0f;
    
    // Remove this view and get rid of it
    [viewTrackingCardImage removeFromSuperview];
    [viewTrackingCard removeFromSuperview];
    viewTrackingCardImage = nil;
    viewTrackingCard = nil;
}

- (UIImage*)mathGameImageForCardIndex:(NSInteger)cardIndex {
    NSString *filename = [filenames objectAtIndex:cardIndex];
    return [UIImage imageNamed:filename];
}

- (void)returnTrackingCardToOriginalLocation {
    CGRect newFrame = CGRectMake(pointTouchOriginal.x - pointTouchOffset.x, pointTouchOriginal.y - pointTouchOffset.y, sizeTouchOriginal.width, sizeTouchOriginal.height);
    
    // Move the tracking card
    [UIView animateWithDuration:0.2f
                     animations:^{
                         viewTrackingCard.frame = newFrame;
                     }
                     completion:^(BOOL finished) {
                         // Show original card
                         viewCurrentAvailableCardView.alpha = 1.0f;
                         
                         // Remove this view and get rid of it
                         [viewTrackingCardImage removeFromSuperview];
                         [viewTrackingCard removeFromSuperview];
                         viewTrackingCardImage = nil;
                         viewTrackingCard = nil;
                     }];
}

- (void)mathGamePairingCardDidFinishUpDownAnimation {
    if (isGameOver == YES) {
        // Show winner/loser views
        if ([winnerId integerValue] == -1) {
            [self performSelector:@selector(displayDraw) withObject:nil afterDelay:1.5f];
        } else if ([winnerId integerValue] == [PTUser currentUser].userID) {
            [self performSelector:@selector(displayWin) withObject:nil afterDelay:1.5f];
        } else {
            [self performSelector:@selector(displayLose) withObject:nil afterDelay:1.5f];
        }
        
        // Start new game after timeout (let the winner fire off new game call!)
        if (([winnerId integerValue] == [PTUser currentUser].userID) || ([winnerId integerValue] == -1 && initiator.userID == [PTUser currentUser].userID)) {
            [self performSelector:@selector(resetGame) withObject:nil afterDelay:6.0f];
        }
    } else {
        // Move pairing cards scroll view
        [self performSelector:@selector(updatePairingScrollViewPosition) withObject:nil afterDelay:0.2f];
    }
}

- (void)mathGamePairingCardDidFinishLeftRightAnimation {
    // Reset the blank view of pairing card
    [viewCurrentPairingCardView resetEmptyCardView];
    
    // Flip gameboard
    [self performSelector:@selector(flipGameBoard) withObject:nil afterDelay:1.5f];
    
    // Set active chat HUD
    [self performSelector:@selector(setActiveChatHUD) withObject:nil afterDelay:1.8f];
}

#pragma mark - Play turn methods

- (void)playTurn {
    // Disable interaction on available cards scroll view
    [self disableAvailableCards];
    
    NSLog(@"Playing card index: %i and %i", currentPairingIndex, currentAvailableIndex);
    PTMatchingPlayTurnRequest *matchingPlayTurnRequest = [[PTMatchingPlayTurnRequest alloc] init];
    [matchingPlayTurnRequest playTurnWithBoardId:boardId
                                      card1Index:currentPairingIndex
                                      card2Index:currentAvailableIndex
                                       authToken:[PTUser currentUser].authToken
                                       onSuccess:^(NSDictionary *result) {
//                                           NSLog(@"Turn success: %@", result);
                                           // Get needed data
                                           NSInteger statusCode = [[result objectForKey:@"status"] integerValue];
                                           NSInteger currentPlayerId = [[result objectForKey:@"playmate_id"] integerValue];
                                           NSInteger whoseTurn = [[result objectForKey:@"turn"] integerValue];
                                           NSInteger initiatorScore = [[result objectForKey:@"initiator_score"] integerValue];
                                           NSInteger playmateScore = [[result objectForKey:@"playmate_score"] integerValue];
                                           NSNumber *_winnerId = [result objectForKey:@"winner_id"];
                                           [self handleGameTurnWithStatusCode:statusCode
                                                                   playmateId:currentPlayerId
                                                                         turn:whoseTurn
                                                               initiatorScore:initiatorScore
                                                                playmateScore:playmateScore
                                                                     winnerId:_winnerId];
                                       }
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
            NSLog(@"Match found! Notify user, slide to next card, switch turn");
            // Set blank side of the pairing card
            [viewCurrentPairingCardView setEmptyCardViewWithImage:[viewCurrentAvailableCardView getCardImage]
                                                      matchedByMe:myTurn];
            
            // Remove tracking card
            if (viewTrackingCard != nil) {
                [viewTrackingCard removeFromSuperview];
                viewTrackingCard = nil;
            }
            
            // Switch whose turn it is
            myTurn = !myTurn;
            
            // Animate the pairing card up and down to show match
            [viewCurrentPairingCardView jumpUpDown];
            
            // Remove available card
            [viewCurrentAvailableCardView removeFromSuperview];
            
            // Tighten up available cards scroll view
            [self updateAvailableScrollViewsPosition];
            
            // Update pairing card index
            currentPairingIndex++;
            
            // Update score
            [self updateScoresWithInitiatorScore:initiatorScore playmateScore:playmateScore];
            break;
        }
            
            // Cards do not match
        case MATCH_ERROR: {
            NSLog(@"Cards not matched. Reset tracking card. Switch turn.");
            // Set blank side of the pairing card
            [viewCurrentPairingCardView setEmptyCardViewWithImage:[viewCurrentAvailableCardView getCardImage] matchedByMe:myTurn];
            
            // Remove tracking card
            if (viewTrackingCard != nil) {
                [viewTrackingCard removeFromSuperview];
                viewTrackingCard = nil;
            }
            
            // Switch whose turn it is
            myTurn = !myTurn;
            
            // Animate the pairing card left and right to show mismatch
            [viewCurrentPairingCardView jumpLeftRight];
            
            // Show available card
            viewCurrentAvailableCardView.alpha = 1.0f;
            break;
        }
            
            // Match won!
        case MATCH_WINNER: {
            NSLog(@"Match won!");
            // Set blank side of the pairing card
            [viewCurrentPairingCardView setEmptyCardViewWithImage:[viewCurrentAvailableCardView getCardImage] matchedByMe:myTurn];
            
            // Remove tracking card
            if (viewTrackingCard != nil) {
                [viewTrackingCard removeFromSuperview];
                viewTrackingCard = nil;
            }
            
            // Set the winner status
            isGameOver = YES;
            winnerId = winnderId;
            
            // Animate the pairing card up and down to show match
            [viewCurrentPairingCardView jumpUpDown];
            
            // Remove available card
            [viewCurrentAvailableCardView removeFromSuperview];
            
            // Update score
            [self updateScoresWithInitiatorScore:initiatorScore playmateScore:playmateScore];
            break;
        }
    }
}

- (void)updateScoresWithInitiatorScore:(NSInteger)initiatorScore playmateScore:(NSInteger)playmateScore {
    NSInteger scoreMe;
    NSInteger scoreOpponent;
    
    // Which score is which?
    if ([PTUser currentUser].userID == initiator.userID) {
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

- (void)updatePairingScrollViewPosition {
    // Slide out current pairing card
    [UIView animateWithDuration:0.25f
                     animations:^{
                         viewCurrentPairingCardView.frame = CGRectOffset(viewCurrentPairingCardView.frame, -viewPairingCards.bounds.size.width, 0.0f);
                         viewCurrentPairingCardView.alpha = 1.0f;
                     }
                     completion:^(BOOL finished) {
                         // Remove old pairing card
                         [viewCurrentPairingCardView removeFromSuperview];

                         // Create new current pairing card
                         viewCurrentPairingCardView = [[PTMathPairingCardView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 553.0f, 235.0f) cardIndex:currentPairingIndex delegate:self];
                         viewCurrentPairingCardView.frame = CGRectMake((viewPairingCards.bounds.size.width-viewCurrentPairingCardView.bounds.size.width)/2.0f + viewPairingCards.bounds.size.width, (viewPairingCards.bounds.size.height-viewCurrentPairingCardView.bounds.size.height)/2.0f, viewCurrentPairingCardView.bounds.size.width, viewCurrentPairingCardView.bounds.size.height); // Move it temporarily off-screen
                         viewCurrentPairingCardView.alpha = 0.0f;
                         
                         // Add it to pairing cards container
                         [viewPairingCards addSubview:viewCurrentPairingCardView];
                         
                         // Slide in the new pairing card
                         [UIView animateWithDuration:0.25f
                                          animations:^{
                                              viewCurrentPairingCardView.frame = CGRectOffset(viewCurrentPairingCardView.frame, -viewPairingCards.bounds.size.width, 0.0f);
                                              
                                              // Only fade in half-way if board isn't active
                                              if (isBoardFlipped == NO) {
                                                  viewCurrentPairingCardView.alpha = 1.0f;
                                              } else {
                                                  viewCurrentPairingCardView.alpha = 0.5f;
                                              }
                                          }
                                          completion:^(BOOL finished) {
                                              // Flip gameboard
                                              [self performSelector:@selector(flipGameBoard) withObject:nil afterDelay:0.2f];
                                              
                                              // Set active chat HUD
                                              [self performSelector:@selector(setActiveChatHUD) withObject:nil afterDelay:0.5f];
                                          }];
                     }];
}

- (void)updateAvailableScrollViewsPosition {
    // Animate all subview to new locations
    __block CGFloat newContentWidth = 25.0f;
    [UIView animateWithDuration:0.3f
                     animations:^{
                         for (PTMathAvailableCardView *viewAvailableCard in viewAvailableCardsScroll.subviews) {
                             CGRect frame = viewAvailableCard.frame;
                             viewAvailableCard.frame = CGRectMake(newContentWidth, frame.origin.y, frame.size.width, frame.size.height);
                             newContentWidth += viewAvailableCard.frame.size.width + 25.0f; // + 25 px spacer
                         }
                     }
                     completion:^(BOOL finished) {
                         [viewAvailableCardsScroll setContentSize:CGSizeMake(newContentWidth, heightAvailableCards)];
                     }];
}

- (void)flipGameBoard {
    // Create a temp image screenshot of the pairing cards container
    UIGraphicsBeginImageContext(viewPairingCards.bounds.size);
    [viewPairingCards.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *imgViewPairingCards = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // Show it
    UIImageView *tempImgViewPairingCards = [[UIImageView alloc] initWithFrame:viewPairingCards.frame];
    tempImgViewPairingCards.image = imgViewPairingCards;
    [viewPairingCardsContainer addSubview:tempImgViewPairingCards];
    
    if (myTurn == YES) {
        // Mark board as not flipped
        isBoardFlipped = NO;
        
        // Make current pairing card visible
        viewCurrentPairingCardView.alpha = 1.0f;
        
        // Change background
        viewPairingCards.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"math-flipboard-front"]];
        viewPairingCards.hidden = YES;
    } else {
        // Mark board as flipped
        isBoardFlipped = YES;
        
        // Make current pairing card less visible
        viewCurrentPairingCardView.alpha = 0.5f;

        // Change background
        viewPairingCards.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"math-flipboard-back"]];
        viewPairingCards.hidden = YES;
    }
    
    // Transition game board
    [UIView transitionFromView:tempImgViewPairingCards
                        toView:viewPairingCards
                      duration:0.5f
                       options:(UIViewAnimationOptionShowHideTransitionViews|UIViewAnimationOptionTransitionFlipFromLeft)
                    completion:^(BOOL finished) {
                        // Remove temporary image view
                        [tempImgViewPairingCards removeFromSuperview];
                        
                        // Show the available cards scroll view
                        if (myTurn == YES) {
                            [self enabledAvailableCards];
                        }
                    }];
}

- (void)setActiveChatHUD {
    // Change active HUD
    if (myTurn == YES) {
        [self.chatController setActiveTurnToRightChatView];
    } else {
        [self.chatController setActiveTurnToLeftChatView];
    }
}

- (PTMathAvailableCardView*)getAvailableCardViewByIndex:(NSInteger)cardIndex {
    for (PTMathAvailableCardView *viewAvailableCard in viewAvailableCardsScroll.subviews) {
        if (cardIndex == [viewAvailableCard getCardIndex]) {
            return viewAvailableCard;
        }
    }
    return nil;
}

- (void)displayWin {
    [self.view insertSubview:winnerView belowSubview:self.chatController.view];
    [UIView animateWithDuration:0.4f animations:^{
        winnerView.alpha = 1.0f;
    }];
}

- (void)displayLose {
    [self.view insertSubview:loserView belowSubview:self.chatController.view];
    [UIView animateWithDuration:0.4f animations:^{
        loserView.alpha = 1.0f;
    }];
}

- (void)displayDraw {
    [self.view insertSubview:drawView belowSubview:self.chatController.view];
    [UIView animateWithDuration:0.4f animations:^{
        drawView.alpha = 1.0f;
    }];
}

- (void)resetGame {
    // Since inititor may have changed, find out real playmate
    // It changes if user that won wasn't the original initiator
    // If they won, they should be the new initiator so they can have the first turn
    NSInteger newPlaymateId;
    if ([PTUser currentUser].userID == initiator.userID) {
        newPlaymateId = playmate.userID;
    } else {
        newPlaymateId = initiator.userID;
    }
    
    // API call to reset the game
    NSInteger randNumCards = 2 * (10 + arc4random() % (21-10+1)); // Random number from 10 to 21 multiplied by 2
    // Gives us number between 20 and 42 (10 to 21 sets)

    PTMatchingRefreshGameRequest *matchingRefreshGameRequest = [[PTMatchingRefreshGameRequest alloc] init];
    [matchingRefreshGameRequest refreshBoardWithInitiatorId:[PTUser currentUser].userID
                                                 playmateId:newPlaymateId
                                                 playdateId:playdate.playdateID
                                                    themeId:2 // Hardcoded
                                                   numCards:randNumCards
                                                   gameName:@"math"
                                                  authToken:[PTUser currentUser].authToken
                                                  onSuccess:nil
                                                  onFailure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                      NSLog(@"Error: %@", error);
                                                      NSLog(@"Error: %@", JSON);
                                                  }];
}

- (void)disableAvailableCards {
    viewAvailableCardsScroll.scrollEnabled = NO;
    [UIView animateWithDuration:0.5f
                     animations:^{
                         //viewAvailableCards.frame = CGRectMake(0.0f, 768.0f-heightAvailableCards-40.0f+80.0f, viewAvailableCards.frame.size.width, viewAvailableCards.frame.size.height);
                         viewAvailableCards.frame = CGRectOffset(viewAvailableCards.frame, 0.0f, 80.0f);
                         viewBottomShawdow.alpha = 1.0f;
                     }];
}

- (void)enabledAvailableCards {
    viewAvailableCardsScroll.scrollEnabled = YES;
    [UIView animateWithDuration:0.5f
                     animations:^{
                         //viewAvailableCards.frame = CGRectMake(0.0f, 768.0f-heightAvailableCards-40.0f, viewAvailableCards.frame.size.width, viewAvailableCards.frame.size.height);
                         viewAvailableCards.frame = CGRectOffset(viewAvailableCards.frame, 0.0f, -80.0f);
                         viewBottomShawdow.alpha = 0.0f;
                     }];
}

#pragma mark - Pusher event handlers

- (void)pusherPlayTurn:(NSNotification*)notification {
    NSDictionary *eventData = notification.userInfo;
//    NSLog(@"pusherPlayTurn: %@", eventData);
    NSInteger statusCode = [[eventData objectForKey:@"status"] integerValue];
    NSInteger currentPlayerId = [[eventData objectForKey:@"playmate_id"] integerValue];
    NSInteger whoseTurn = [[eventData objectForKey:@"turn"] integerValue];
    
    // Verify that it wasn't us who took this turn
    if (currentPlayerId != [[PTUser currentUser] userID]) {
        // Get available card index
        NSNumber *card2 = [eventData objectForKey:@"card2_index"];
        currentAvailableIndex = [card2 integerValue];
        
        // Find the card
        viewCurrentAvailableCardView = [self getAvailableCardViewByIndex:currentAvailableIndex];
        
        NSInteger initiatorScore = [[eventData objectForKey:@"initiator_score"] integerValue];
        NSInteger playmateScore = [[eventData objectForKey:@"playmate_score"] integerValue];
        NSNumber *_winnerId = [eventData objectForKey:@"winner_id"];
        [self handleGameTurnWithStatusCode:statusCode
                                playmateId:currentPlayerId
                                      turn:whoseTurn
                            initiatorScore:initiatorScore
                             playmateScore:playmateScore
                                  winnerId:_winnerId];
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
    NSDictionary *eventData = notification.userInfo;
    
    // Get response parameters
    NSInteger initiatorId = [[eventData objectForKey:@"initiator_id"] integerValue];
    NSInteger _boardId = [[eventData objectForKey:@"board_id"] integerValue];
    NSInteger _totalCards = [[eventData objectForKey:@"num_cards"] integerValue];
    NSString *filenamesFlat = [eventData valueForKey:@"filename_dump"];
    filenamesFlat = [filenamesFlat substringWithRange:NSMakeRange(2, [filenamesFlat length] - 4)];
    NSArray *_filenames = [filenamesFlat componentsSeparatedByString:@"\",\""];
    NSString *cardsString = [eventData valueForKey:@"card_array_string"];
    
    PTPlaymate *aInitiator;
    PTPlaymate *aPlaymate;
    if (playdate.initiator.userID == initiatorId) {
        aInitiator = playdate.initiator;
        aPlaymate = playdate.playmate;
    } else {
        aInitiator = playdate.playmate;
        aPlaymate = playdate.initiator;
    }
    
    // My turn?
    BOOL isMyTurn = [PTUser currentUser].userID == initiatorId;
    
    // Init the math game controller
    PTMathViewController *mathViewController = [[PTMathViewController alloc]
                                                initWithNibName:@"PTMathViewController"
                                                bundle:nil
                                                playdate:playdate
                                                boardId:_boardId
                                                themeId:2 // TODO: Hard coded
                                                initiator:aInitiator
                                                playmate:aPlaymate
                                                filenames:_filenames
                                                totalCards:_totalCards
                                                cardsString:cardsString
                                                myTurn:isMyTurn];
    mathViewController.chatController = self.chatController;
    
    // Init game splash
    UIImageView *splash =  [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 1024.0f, 768.0f)];
    splash.image = [UIImage imageNamed:@"math-splash"];
    
    // Notifications cleanup
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    // Bring up the view controller of the new game
    PTAppDelegate* appDelegate = (PTAppDelegate*)[[UIApplication sharedApplication] delegate];
    [appDelegate.transitionController loadGame:mathViewController
                                   withOptions:UIViewAnimationOptionTransitionCurlUp
                                    withSplash:splash];
}

@end