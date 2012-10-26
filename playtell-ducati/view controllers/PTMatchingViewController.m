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

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil
             playdate:(PTPlaydate *)_playdate
              boardId:(NSInteger)_boardId
              themeId:(NSInteger)_themeId
            initiator:(PTPlaymate *)_initiator
             playmate:(PTPlaymate *)_playmate
            filenames:(NSArray *)_filenames
           totalCards:(NSInteger)_totalCards
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
        totalCards = _totalCards;
        myTurn = _myTurn;
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
    [self.view insertSubview:viewBgShim atIndex:0];
    
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
    viewAvailableCardsScroll.backgroundColor = [UIColor greenColor];
    viewAvailableCardsScroll.clipsToBounds = NO;
    viewAvailableCardsScroll.userInteractionEnabled = YES;
    viewAvailableCardsScroll.canCancelContentTouches = NO;
    viewAvailableCardsScroll.delaysContentTouches = YES;
    viewAvailableCardsScroll.showsHorizontalScrollIndicator = NO;
    viewAvailableCardsScroll.pagingEnabled = YES;
    [viewAvailableCards addSubview:viewAvailableCardsScroll];
    
    // Setup available cards
    CGFloat x = 0.0f;
    CGSize sizeCard = CGSizeMake(140.0f, 160.0f); // 120 card width + 10 padding on each side
    for (int i=0; i<totalCards; i++) {
        PTMatchingAvailableCardView *viewCard = [[PTMatchingAvailableCardView alloc] initWithFrame:CGRectMake(x, 0.0f, sizeCard.width, sizeCard.height) cardIndex:i];
        viewCard.delegate = self;
        [viewAvailableCardsScroll addSubview:viewCard];
        x += sizeCard.width;
    }
    [viewAvailableCardsScroll setContentSize:CGSizeMake((totalCards * sizeCard.width), 150.0f)];
    
    // Setup pairing cards container
    viewPairingCards = [[PTMatchingPairingCardsView alloc] initWithFrame:CGRectMake(10.0f, 200.0f, 1004.0f, 286.0f)];
    viewPairingCards.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"matching-flipboard-me"]];
    [self.view addSubview:viewPairingCards];
    viewPairingCardsScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(352.0f, 43.0f, 300.0f, 200.0f)];
    viewPairingCardsScroll.tag = 2;
    viewPairingCardsScroll.delegate = self;
    viewPairingCardsScroll.backgroundColor = [UIColor greenColor];
    viewPairingCardsScroll.clipsToBounds = NO;
    viewPairingCardsScroll.userInteractionEnabled = YES;
    viewPairingCardsScroll.canCancelContentTouches = NO;
    viewPairingCardsScroll.delaysContentTouches = YES;
    viewPairingCardsScroll.showsHorizontalScrollIndicator = NO;
    viewPairingCardsScroll.pagingEnabled = YES;
    [viewPairingCards addSubview:viewPairingCardsScroll];
    
    // Setup pairing cards
    x = 0.0f;
    sizeCard = CGSizeMake(300.0f, 200.0f);
    for (int i=0; i<totalCards; i++) {
        PTMatchingPairingCardView *viewCard = [[PTMatchingPairingCardView alloc] initWithFrame:CGRectMake(x, 0.0f, sizeCard.width, sizeCard.height) cardIndex:i];
        //viewCard.delegate = self;
        [viewPairingCardsScroll addSubview:viewCard];
        x += sizeCard.width;
    }
    [viewPairingCardsScroll setContentSize:CGSizeMake((totalCards * sizeCard.width), 200.0f)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
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
            [(PTMatchingPairingCardView *)[scrollView.subviews objectAtIndex:i] setFocusLevel:level];
        }
    }
}

#pragma mark - Mathing game delegates

- (void)matchingGameAvailableCardTouchesBegan:(PTMatchingAvailableCardView *)cardView touch:(UITouch *)touch {
    // Figure out the points on the screen relative to the touch
    pointTouchOriginal = [touch locationInView:self.view];
    pointTouchOffset = [touch locationInView:cardView];
    viewTrackingCard = [[UIView alloc] initWithFrame:CGRectMake(pointTouchOriginal.x - pointTouchOffset.x + 10.0f, pointTouchOriginal.y - pointTouchOffset.y, 120.0f, 160.0f)];
    viewTrackingCard.backgroundColor = [UIColor yellowColor];
    [self.view addSubview:viewTrackingCard];
    
    // Grow card a bit
    [UIView animateWithDuration:0.2f
                     animations:^{
                         viewTrackingCard.frame = CGRectMake(viewTrackingCard.frame.origin.x - 8.0f, viewTrackingCard.frame.origin.y - 10.0f, 136.0f, 180.0f);
                     }];
    
    // Hide the card
    viewOriginalTrackingCard = cardView;
    viewOriginalTrackingCard.alpha = 0.0f;
}

- (void)matchingGameAvailableCardTouchesMoved:(PTMatchingAvailableCardView *)cardView touch:(UITouch *)touch {
    // TODO: See if this point is near the landing box
    CGPoint point = [touch locationInView:self.view];
//    NSLog(@"moved: %@", NSStringFromCGPoint(point));
    viewTrackingCard.frame = CGRectMake(point.x - pointTouchOffset.x + 10.0f, point.y - pointTouchOffset.y, 136.0f, 180.0f);
}

- (void)matchingGameAvailableCardTouchesEnded:(PTMatchingAvailableCardView *)cardView touch:(UITouch *)touch {
    // TODO: See if this point is near the landing box
    // CGPoint point = [touch locationInView:self.view];

    // If not near landing box, go back to its original location
    [UIView animateWithDuration:0.2f
                     animations:^{
                         viewTrackingCard.frame = CGRectMake(pointTouchOriginal.x - pointTouchOffset.x + 10.0f, pointTouchOriginal.y - pointTouchOffset.y, 120.0f, 160.0f);
                     }
                     completion:^(BOOL finished) {
                         // Show original card
                         viewOriginalTrackingCard.alpha = 1.0f;
                         
                         // Remove this view and get rid of it
                         [viewTrackingCard removeFromSuperview];
                         viewTrackingCard = nil;
                     }];
}

- (void)matchingGameAvailableCardTouchesCancelled:(PTMatchingAvailableCardView *)cardView touch:(UITouch *)touch {
    // Show original card
    viewOriginalTrackingCard.alpha = 1.0f;
    
    // Remove this view and get rid of it
    [viewTrackingCard removeFromSuperview];
    viewTrackingCard = nil;
}

@end