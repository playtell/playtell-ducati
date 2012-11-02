//
//  PTMatchingViewController.m
//  playtell-ducati
//
//  Created by Dimitry Bentsionov on 10/23/12.
//  Copyright (c) 2012 PlayTell. All rights reserved.
//

#import "PTMatchingViewController.h"
#import "PTMatchingEndGameRequest.h"
#import "PTMatchingPlayTurnRequest.h"
#import "PTMatchingRefreshGameRequest.h"
#import "PTUser.h"
#import "PTAppDelegate.h"
#import "TransitionController.h"
#import "PTDialpadViewController.h"
#import "PTPlaydateDisconnectRequest.h"
#import "PTMatchingAvailableCardView.h"
#import "PTMatchingPairingCardView.h"

@interface PTMatchingViewController ()

@end

@implementation PTMatchingViewController

@synthesize chatController;

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
        NSMutableArray *stringBuffer = [NSMutableArray arrayWithCapacity:[_cardsString length]];
        for (int i=0; i<[_cardsString length]; i++) {
            [stringBuffer addObject:[NSString stringWithFormat:@"%C", [_cardsString characterAtIndex:i]]];
        }
        pairingCards = [NSArray arrayWithArray:[stringBuffer subarrayWithRange:NSMakeRange(0, totalCards)]];
        availableCards = [NSArray arrayWithArray:[stringBuffer subarrayWithRange:NSMakeRange(totalCards, totalCards)]];
        
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
    if (myTurn == YES) {
        self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"matching-green-bg"]];
    } else {
        self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"matching-orangeblur-bg"]];
    }
    viewBgShim = [[UIView alloc] initWithFrame:self.view.bounds];
    viewBgShim.hidden = YES;
    [self.view insertSubview:viewBgShim atIndex:0];
    
    // Display chat HUD
    [self.view addSubview:self.chatController.view];
    
    // Setup "end playdate" button
    endPlaydate.layer.shadowColor = [UIColor blackColor].CGColor;
    endPlaydate.layer.shadowOffset = CGSizeMake(0.0f, 2.0f);
    endPlaydate.layer.shadowOpacity = 0.2f;
    endPlaydate.layer.shadowRadius = 6.0f;
    
    // Setup available cards container
    viewAvailableCards = [[PTMatchingAvailableCardsView alloc] initWithFrame:CGRectMake(0.0f, 768.0f-160.0f-30.0f, 1024.0f, 160.0f)];
    [self.view addSubview:viewAvailableCards];
    viewAvailableCardsScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(442.0f, 0.0f, 140.0f, 160.0f)];
    viewAvailableCardsScroll.tag = 1;
    viewAvailableCardsScroll.delegate = self;
    viewAvailableCardsScroll.clipsToBounds = NO;
    viewAvailableCardsScroll.userInteractionEnabled = YES;
    viewAvailableCardsScroll.canCancelContentTouches = NO;
    viewAvailableCardsScroll.delaysContentTouches = YES;
    viewAvailableCardsScroll.showsHorizontalScrollIndicator = NO;
    viewAvailableCardsScroll.showsVerticalScrollIndicator = NO;
    viewAvailableCardsScroll.pagingEnabled = YES;
    [viewAvailableCards addSubview:viewAvailableCardsScroll];
    
    // Setup available cards
    [self setupAvailableCards];
    
    // Setup pairing cards container
    viewPairingCardsContainer = [[UIView alloc] initWithFrame:CGRectMake(10.0f, 200.0f, 1004.0f, 286.0f)];
    viewPairingCards = [[PTMatchingPairingCardsView alloc] initWithFrame:viewPairingCardsContainer.bounds];
    viewPairingCards.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"matching-flipboard-me"]];
    viewPairingCards.clipsToBounds = YES;
    [viewPairingCardsContainer addSubview:viewPairingCards];
    [self.view addSubview:viewPairingCardsContainer];
    viewPairingCardsScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(352.0f, 43.0f, 300.0f, 200.0f)];
    viewPairingCardsScroll.tag = 2;
    viewPairingCardsScroll.delegate = self;
    viewPairingCardsScroll.clipsToBounds = NO;
    viewPairingCardsScroll.userInteractionEnabled = YES;
    viewPairingCardsScroll.canCancelContentTouches = NO;
    viewPairingCardsScroll.delaysContentTouches = YES;
    viewPairingCardsScroll.showsHorizontalScrollIndicator = NO;
    viewPairingCardsScroll.showsVerticalScrollIndicator = NO;
    viewPairingCardsScroll.pagingEnabled = YES;
    viewPairingCardsScroll.scrollEnabled = NO;
    [viewPairingCards addSubview:viewPairingCardsScroll];
    
    // Setup pairing cards
    [self setupPairingCards];
    
    // If not my turn, flip the game board
    if (myTurn == NO) {
        [self performSelector:@selector(flipGameBoard) withObject:nil afterDelay:0.8f];
        [self disableAvailableCards];
    }
    
    // Winner/loser views
    winnerView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 465.0f, 394.0f)];
    winnerView.center = self.view.center;
    winnerView.image = [UIImage imageNamed:@"memory-win"];
    winnerView.alpha = 0.0f;
    loserView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 465.0f, 394.0f)];
    loserView.center = self.view.center;
    loserView.image = [UIImage imageNamed:@"memory-win"]; // Everybody wins!
    loserView.alpha = 0.0f;
    drawView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 465.0f, 394.0f)];
    drawView.center = self.view.center;
    drawView.backgroundColor = [UIColor blackColor];
    drawView.image = [UIImage imageNamed:@"memory-win"]; // Everybody wins!
    drawView.alpha = 0.0f;
    
    // Score views
    scoreViewMe = [[PTMatchingScoreView alloc] initWithFrame:CGRectMake(768.0f, 75.0f, 56.0f, 75.0f) myScore:YES];
    [self.view addSubview:scoreViewMe];
    scoreViewOpponent = [[PTMatchingScoreView alloc] initWithFrame:CGRectMake(200.0f, 75.0f, 56.0f, 75.0f) myScore:NO];
    [self.view addSubview:scoreViewOpponent];
    
    // Bottom shadow
    viewBottomShawdow = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 733.0f, 1024.0f, 35.0f)];
    viewBottomShawdow.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"matching-bottom-shadow"]];
    viewBottomShawdow.alpha = 0;
    [self.view insertSubview:viewBottomShawdow belowSubview:viewPairingCards];
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

- (void)setupPairingCards {
    int x = 0.0f;
    CGSize sizeCard = CGSizeMake(300.0f, 200.0f);
    for (int i=0; i<totalCards; i++) {
        PTMatchingPairingCardView *viewCard = [[PTMatchingPairingCardView alloc] initWithFrame:CGRectMake(x, 0.0f, sizeCard.width, sizeCard.height) cardIndex:i delegate:self];
        [viewPairingCardsScroll addSubview:viewCard];
        x += sizeCard.width;
    }
    [viewPairingCardsScroll setContentSize:CGSizeMake((totalCards * sizeCard.width), 200.0f)];
    [self scrollViewDidScroll:viewPairingCardsScroll]; // Resize all children appropriately first time around
    rectLandingStrip = CGRectMake(356.0f, 237.0f, 156.0f, 212.0f);
    
    // Set the first card as the "current index"
    currentPairingIndex = 0;
    viewCurrentPairingCardView = (PTMatchingPairingCardView *)[viewPairingCardsScroll.subviews objectAtIndex:0];
}

- (void)setupAvailableCards {
    CGFloat x = 0.0f;
    CGSize sizeCard = CGSizeMake(140.0f, 160.0f); // 120 card width + 10 padding on each side
    for (int i=0; i<totalCards; i++) {
        PTMatchingAvailableCardView *viewCard = [[PTMatchingAvailableCardView alloc] initWithFrame:CGRectMake(x, 0.0f, sizeCard.width, sizeCard.height) cardIndex:(i+totalCards) delegate:self];
        [viewAvailableCardsScroll addSubview:viewCard];
        x += sizeCard.width;
    }
    [viewAvailableCardsScroll setContentSize:CGSizeMake((totalCards * sizeCard.width), 150.0f)];
}

#pragma mark - Game actions

- (IBAction)endGame:(id)sender {
    // API call to end the game
    PTMatchingEndGameRequest *endGameRequest = [[PTMatchingEndGameRequest alloc] init];
    [endGameRequest endGameWithBoardId:boardId
                             authToken:[PTUser currentUser].authToken
                             onSuccess:nil
                             onFailure:nil];

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

- (void)matchingGameAvailableCardTouchesBegan:(PTMatchingAvailableCardView *)cardView touch:(UITouch *)touch {
    if (viewAvailableCardsScroll.scrollEnabled == NO) {
        return;
    }

    // Figure out the points on the screen relative to the touch
    pointTouchOriginal = [touch locationInView:self.view];
    pointTouchOffset = [touch locationInView:cardView];
    viewTrackingCard = [[UIView alloc] initWithFrame:CGRectMake(pointTouchOriginal.x - pointTouchOffset.x + 10.0f - 6.0f, pointTouchOriginal.y - pointTouchOffset.y - 6.0f, 126.0f, 172.0f)];
    viewTrackingCard.backgroundColor = [UIColor whiteColor];
    viewTrackingCardImage = [[UIImageView alloc] initWithFrame:CGRectMake(6.0f, 6.0f, 120.0f, 160.0f)];
    viewTrackingCardImage.image = [cardView getCardImage];
    [viewTrackingCard addSubview:viewTrackingCardImage];
    [self.view addSubview:viewTrackingCard];
    
    // Tracking card shadow
    viewTrackingCard.layer.masksToBounds = NO;
    viewTrackingCard.layer.shadowColor = [UIColor blackColor].CGColor;
    viewTrackingCard.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
    viewTrackingCard.layer.shadowOpacity = 0.8f;
    viewTrackingCard.layer.shadowRadius = 6.0f;
    viewTrackingCard.layer.shouldRasterize = YES;
    viewTrackingCard.layer.shadowPath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, viewTrackingCard.frame.size.height - 2, viewTrackingCard.frame.size.width, 10)].CGPath;
    
    canTrackingCardLand = NO;
    isTrackingCardSmall = YES;
    
    // Save currently selected views
    currentAvailableIndex = [cardView getCardIndex];
    viewCurrentAvailableCardView = cardView;
    
    // Grow card a bit
    CGRect newFrame = CGRectMake(viewTrackingCard.frame.origin.x - 8.0f, viewTrackingCard.frame.origin.y - 10.0f, 142.0f, 192.0f);
    [UIView animateWithDuration:0.2f
                     animations:^{
                         viewTrackingCard.frame = newFrame;
                         viewTrackingCardImage.frame = CGRectMake(6.0f, 6.0f, 136.0f, 180.0f);
                     }];
    
    // Grow the shadow
    CABasicAnimation *theAnimation = [CABasicAnimation animationWithKeyPath:@"shadowPath"];
    theAnimation.duration = 0.2f;
    theAnimation.fromValue = (id)viewTrackingCard.layer.shadowPath;
    theAnimation.toValue = (id)[UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, newFrame.size.height - 2, newFrame.size.width, 10)].CGPath;
    [viewTrackingCard.layer addAnimation:theAnimation forKey:@"shadowPath"];
    viewTrackingCard.layer.shadowPath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, newFrame.size.height - 2, newFrame.size.width, 10)].CGPath;
    
    // Hide the card
    viewOriginalTrackingCard = cardView;
    viewOriginalTrackingCard.alpha = 0.0f;
}

- (void)matchingGameAvailableCardTouchesMoved:(PTMatchingAvailableCardView *)cardView touch:(UITouch *)touch {
    if (viewAvailableCardsScroll.scrollEnabled == NO) {
        return;
    }
    
    // See if this point is near the landing box
    CGPoint point = [touch locationInView:self.view];
    
    // Get all 4 points of the card
    CGPoint pointTopLeft = CGPointMake(point.x - pointTouchOffset.x - 6.0f, point.y - pointTouchOffset.y - 6.0f);
    CGPoint pointTopRight = CGPointMake(pointTopLeft.x + viewTrackingCard.frame.size.width, pointTopLeft.y);
    CGPoint pointBottomRight = CGPointMake(pointTopLeft.x + viewTrackingCard.frame.size.width, pointTopLeft.y + viewTrackingCard.frame.size.height);
    CGPoint pointBottomLeft = CGPointMake(pointTopLeft.x, pointTopLeft.y + viewTrackingCard.frame.size.height);
    
    // Figure out if card can land
    canTrackingCardLand = CGRectContainsPoint(rectLandingStrip, pointTopLeft) || CGRectContainsPoint(rectLandingStrip, pointBottomRight) || CGRectContainsPoint(rectLandingStrip, pointTopRight) || CGRectContainsPoint(rectLandingStrip, pointBottomLeft);

    // Redraw its location and size accordingly
    if (canTrackingCardLand) {
        viewTrackingCard.frame = CGRectMake(point.x - pointTouchOffset.x + 10.0f - 6.0f, point.y - pointTouchOffset.y - 6.0f, 156.0f, 212.0f);
        viewTrackingCardImage.frame = CGRectMake(6.0f, 6.0f, 150.0f, 200.0f);
    } else {
        viewTrackingCard.frame = CGRectMake(point.x - pointTouchOffset.x + 10.0f - 12.0f, point.y - pointTouchOffset.y - 12.0f, 142.0f, 192.0f);
        viewTrackingCardImage.frame = CGRectMake(6.0f, 6.0f, 136.0f, 180.0f);
    }
    
    // Update shadow position
    viewTrackingCard.layer.shadowPath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, viewTrackingCard.frame.size.height - 2, viewTrackingCard.frame.size.width, 10)].CGPath;
}

- (void)matchingGameAvailableCardTouchesEnded:(PTMatchingAvailableCardView *)cardView touch:(UITouch *)touch {
    if (viewAvailableCardsScroll.scrollEnabled == NO) {
        return;
    }
    
    // Can we land?
    if (canTrackingCardLand == YES) {
        // Move it to its resting spot next to the right card
        CGRect newFrame = rectLandingStrip;
        [UIView animateWithDuration:0.2f
                         animations:^{
                             viewTrackingCard.frame = newFrame;
                         }
                         completion:^(BOOL finished) {
                             // API call to play turn
                             [self playTurn];
                         }];
        
        // Shrink the shadow
        CABasicAnimation *theAnimation = [CABasicAnimation animationWithKeyPath:@"shadowPath"];
        theAnimation.duration = 0.2f;
        theAnimation.fromValue = (id)viewTrackingCard.layer.shadowPath;
        theAnimation.toValue = (id)[UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, newFrame.size.height - 2, newFrame.size.width, 10)].CGPath;
        [viewTrackingCard.layer addAnimation:theAnimation forKey:@"shadowPath"];
        viewTrackingCard.layer.shadowPath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, newFrame.size.height - 2, newFrame.size.width, 10)].CGPath;
    } else {
        // If not near landing box, go back to its original location
        [self returnTrackingCardToOriginalLocation];
    }
}

- (void)matchingGameAvailableCardTouchesCancelled:(PTMatchingAvailableCardView *)cardView touch:(UITouch *)touch {
    if (viewAvailableCardsScroll.scrollEnabled == NO) {
        return;
    }
    
    // Show original card
    viewOriginalTrackingCard.alpha = 1.0f;
    
    // Remove this view and get rid of it
    [viewTrackingCardImage removeFromSuperview];
    [viewTrackingCard removeFromSuperview];
    viewTrackingCardImage = nil;
    viewTrackingCard = nil;
}

- (UIImage*)matchingGameImageForCardIndex:(NSInteger)cardIndex {
    NSString *filename = [filenames objectAtIndex:cardIndex];
    return [UIImage imageNamed:filename];
}

- (void)returnTrackingCardToOriginalLocation {
    CGRect newFrame = CGRectMake(pointTouchOriginal.x - pointTouchOffset.x + 10.0f - 6.0f, pointTouchOriginal.y - pointTouchOffset.y - 6.0f, 126.0f, 172.0f);
    
    // Move the tracking card
    [UIView animateWithDuration:0.2f
                     animations:^{
                         viewTrackingCard.frame = newFrame;
                         viewTrackingCardImage.frame = CGRectMake(6.0f, 6.0f, 120.0f, 160.0f);
                     }
                     completion:^(BOOL finished) {
                         // Show original card
                         viewOriginalTrackingCard.alpha = 1.0f;
                         
                         // Remove this view and get rid of it
                         [viewTrackingCardImage removeFromSuperview];
                         [viewTrackingCard removeFromSuperview];
                         viewTrackingCardImage = nil;
                         viewTrackingCard = nil;
                     }];
    
    // Shrink the shadow
    CABasicAnimation *theAnimation = [CABasicAnimation animationWithKeyPath:@"shadowPath"];
    theAnimation.duration = 0.2f;
    theAnimation.fromValue = (id)viewTrackingCard.layer.shadowPath;
    theAnimation.toValue = (id)[UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, newFrame.size.height - 2, newFrame.size.width, 10)].CGPath;
    [viewTrackingCard.layer addAnimation:theAnimation forKey:@"shadowPath"];
    viewTrackingCard.layer.shadowPath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, newFrame.size.height - 2, newFrame.size.width, 10)].CGPath;
}

- (void)matchingGamePairingCardDidFinishUpDownAnimation {
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

- (void)matchingGamePairingCardDidFinishLeftRightAnimation {
    // Reset the blank view of pairing card
    [viewCurrentPairingCardView resetEmptyCardView];

    // Flip gameboard
    [self performSelector:@selector(flipGameBoard) withObject:nil afterDelay:1.5f];
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
                                           NSLog(@"Turn success: %@", result);
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
            [viewCurrentPairingCardView setEmptyCardViewWithImage:[viewCurrentAvailableCardView getCardImage] matchedByMe:myTurn];
            
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
    if (isBoardFlipped == NO) {
        [viewPairingCardsScroll setContentOffset:CGPointMake((currentPairingIndex*viewCurrentPairingCardView.frame.size.width), 0.0f) animated:YES];
    } else {
        [viewPairingCardsScroll setContentOffset:CGPointMake(((totalCards - currentPairingIndex - 1)*viewCurrentPairingCardView.frame.size.width), 0.0f) animated:YES];
    }
    
    // Flip gameboard
    [self performSelector:@selector(flipGameBoard) withObject:nil afterDelay:0.7f];
}

- (void)updateAvailableScrollViewsPosition {
    // Figure out new scroll view content width
    CGFloat newContentWidth = viewAvailableCardsScroll.frame.size.width * [viewAvailableCardsScroll.subviews count];
    //CGFloat currentContentWidth = viewAvailableCardsScroll.contentOffset.x;
    [viewAvailableCardsScroll setContentSize:CGSizeMake(newContentWidth, 150.0f)];
    
    // Animate all subview to new locations
    [UIView animateWithDuration:0.3f
                     animations:^{
                         int i=0;
                         for (PTMatchingAvailableCardView *viewAvailableCard in viewAvailableCardsScroll.subviews) {
                             CGRect frame = viewAvailableCard.frame;
                             viewAvailableCard.frame = CGRectMake(viewAvailableCardsScroll.frame.size.width * i, frame.origin.y, frame.size.width, frame.size.height);
                             i++;
                         }
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
        // Now that view pairing cards scroll view is underneath, flip its children back to normal
        int i = 0;
        for (PTMatchingPairingCardView *viewPairingCard in viewPairingCardsScroll.subviews) {
            [viewPairingCard resetTransformation];
            CGRect frame = viewPairingCard.frame;
            viewPairingCard.frame = CGRectMake(viewPairingCardsScroll.frame.size.width * i, 0.0f, frame.size.width, frame.size.height);
            i++;
            
            // Flip the card
            [viewPairingCard flipCardsToNormal];
        }
        isBoardFlipped = NO;
        
        // Flip content position of pairing scroll view
        [viewPairingCardsScroll setContentOffset:CGPointMake(viewPairingCardsScroll.frame.size.width * currentPairingIndex, 0)];
        [self scrollViewDidScroll:viewPairingCardsScroll]; // Resize all children appropriately
        
        // Change background
        viewPairingCards.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"matching-flipboard-me"]];
        viewPairingCards.hidden = YES;
    } else {
        // Now that view pairing cards scroll view is underneath, flip its children
        int i = 0;
        for (PTMatchingPairingCardView *viewPairingCard in viewPairingCardsScroll.subviews) {
            [viewPairingCard resetTransformation];
            i++;
            CGRect frame = viewPairingCard.frame;
            viewPairingCard.frame = CGRectMake(viewPairingCardsScroll.frame.size.width * (totalCards - i), 0.0f, frame.size.width, frame.size.height);

            // Flip the card
            [viewPairingCard flipCardsToMirror];
        }
        isBoardFlipped = YES;
        
        // Flip content position of pairing scroll view
        [viewPairingCardsScroll setContentOffset:CGPointMake(viewPairingCardsScroll.frame.size.width * (totalCards - currentPairingIndex - 1), 0)];
        [self scrollViewDidScroll:viewPairingCardsScroll]; // Resize all children appropriately
        
        // Change background
        viewPairingCards.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"matching-flipboard-you"]];
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
                        
                        // Set current pairing card view
                        viewCurrentPairingCardView = (PTMatchingPairingCardView *)[viewPairingCardsScroll.subviews objectAtIndex:currentPairingIndex];
                        
                        // Show the available cards scroll view
                        if (myTurn == YES) {
                            [self enabledAvailableCards];
                        }
                    }];
    
    // Switch background
    UIImage *imgNewBg;
    if (myTurn == YES) {
        imgNewBg = [UIImage imageNamed:@"matching-green-bg"];
    } else {
        imgNewBg = [UIImage imageNamed:@"matching-orangeblur-bg"];
    }
    viewBgShim.backgroundColor = [UIColor colorWithPatternImage:imgNewBg];
    viewBgShim.alpha = 0.0f;
    viewBgShim.hidden = NO;
    [UIView animateWithDuration:0.5f
                     animations:^{
                         viewBgShim.alpha = 1.0f;
                     }
                     completion:^(BOOL finished) {
                         viewBgShim.hidden = YES;
                         self.view.backgroundColor = [UIColor colorWithPatternImage:imgNewBg];
                     }];
}

- (PTMatchingAvailableCardView*)getAvailableCardViewByIndex:(NSInteger)cardIndex {
    for (PTMatchingAvailableCardView *viewAvailableCard in viewAvailableCardsScroll.subviews) {
        if (cardIndex == [viewAvailableCard getCardIndex]) {
            return viewAvailableCard;
        }
    }
    return nil;
}

- (void)displayWin {
    [self.view addSubview:winnerView];
    [UIView animateWithDuration:0.4f animations:^{
        winnerView.alpha = 1.0f;
    }];
}

- (void)displayLose {
    [self.view addSubview:loserView];
    [UIView animateWithDuration:0.4f animations:^{
        loserView.alpha = 1.0f;
    }];
}

- (void)displayDraw {
    [self.view addSubview:drawView];
    [UIView animateWithDuration:0.4f animations:^{
        drawView.alpha = 1.0f;
    }];
}

- (void)resetGame {
    NSLog(@"NEW GAME BITCHES");
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
    NSInteger randNumCards = 2 * (arc4random_uniform(4) + 2); // Random number from 2 to 6 multiplied by 2 to get an even number from 2 to 12
    PTMatchingRefreshGameRequest *matchingRefreshGameRequest = [[PTMatchingRefreshGameRequest alloc] init];
    [matchingRefreshGameRequest refreshBoardWithInitiatorId:[PTUser currentUser].userID
                                                 playmateId:newPlaymateId
                                                 playdateId:playdate.playdateID
                                                    themeId:19 // Hardcoded
                                                   numCards:randNumCards
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
                         viewAvailableCards.frame = CGRectMake(0.0f, 768.0f-160.0f-30.0f+80.0f, 1024.0f, 160.0f);
                         viewBottomShawdow.alpha = 1;
                     }];
}

- (void)enabledAvailableCards {
    viewAvailableCardsScroll.scrollEnabled = YES;
    [UIView animateWithDuration:0.5f
                     animations:^{
                         viewAvailableCards.frame = CGRectMake(0.0f, 768.0f-160.0f-30.0f, 1024.0f, 160.0f);
                         viewBottomShawdow.alpha = 0;
                     }];
}

#pragma mark - Pusher event handlers

- (void)pusherPlayTurn:(NSNotification*)notification {
    NSDictionary *eventData = notification.userInfo;
    NSLog(@"pusherPlayTurn: %@", eventData);
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
        // Transition to playdate view controller
        PTAppDelegate* appDelegate = (PTAppDelegate*)[[UIApplication sharedApplication] delegate];
        [appDelegate.transitionController transitionToViewController:[appDelegate dateViewController] withOptions:UIViewAnimationOptionTransitionCrossDissolve];
    }
}

- (void)pusherRefreshGame:(NSNotification*)notification {
    NSDictionary *eventData = notification.userInfo;
    boardId = [[eventData objectForKey:@"board_id"] integerValue];
    totalCards = ([[eventData objectForKey:@"num_cards"] integerValue]/2.0f); // Really there are twice as many, but they're all halves
    
    // Parse file names
    NSString *filenamesFlat = [eventData valueForKey:@"filename_dump"];
    filenamesFlat = [filenamesFlat substringWithRange:NSMakeRange(2, [filenamesFlat length] - 4)];
    filenames = [filenamesFlat componentsSeparatedByString:@"\",\""];
    
    // Parse cards string
    NSString *_cardsString = [eventData objectForKey:@"card_array_string"];
    NSMutableArray *stringBuffer = [NSMutableArray arrayWithCapacity:[_cardsString length]];
    for (int i=0; i<[_cardsString length]; i++) {
        [stringBuffer addObject:[NSString stringWithFormat:@"%C", [_cardsString characterAtIndex:i]]];
    }
    pairingCards = [NSArray arrayWithArray:[stringBuffer subarrayWithRange:NSMakeRange(0, totalCards)]];
    availableCards = [NSArray arrayWithArray:[stringBuffer subarrayWithRange:NSMakeRange(totalCards, totalCards)]];
    
    // Figure out the roles of the players
    NSInteger initiatorId = [[eventData objectForKey:@"initiator_id"] integerValue];
    if ([[PTUser currentUser] userID] == initiatorId) {
        initiator = [PTUser currentUser];
        playmate = playdate.playmate;
        myTurn = YES;
    } else {
        initiator = playdate.playmate;
        playmate = [PTUser currentUser];
        myTurn = NO;
    }
    
    // Reset game status
    isGameOver = NO;
    
    // Hide win/lose/draw popups
    [UIView animateWithDuration:0.2f animations:^{
        winnerView.alpha = 0.0f;
        loserView.alpha = 0.0f;
        drawView.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [winnerView removeFromSuperview];
        [loserView removeFromSuperview];
        [drawView removeFromSuperview];
    }];
    
    // Reset Game background & game board flip position
    if (myTurn == YES) {
        self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"matching-green-bg"]];
    } else {
        self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"matching-orangeblur-bg"]];
    }
    viewPairingCards.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"matching-flipboard-me"]];
    
    // Reset all pairing and available card subview
    for (UIView *childView in viewAvailableCardsScroll.subviews) {
        [childView removeFromSuperview];
    }
    for (UIView *childView in viewPairingCardsScroll.subviews) {
        [childView removeFromSuperview];
    }
    [self setupAvailableCards];
    [self setupPairingCards];
    
    // Reset scores
    [scoreViewMe setScore:0];
    [scoreViewOpponent setScore:0];
    
    // If not my turn, flip the game board
    if (myTurn == NO) {
        [self performSelector:@selector(flipGameBoard) withObject:nil afterDelay:0.8f];
        [self disableAvailableCards];
    } else {
        [self enabledAvailableCards];
    }
}

@end