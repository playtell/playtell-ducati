//
//  PTMathViewController.h
//  playtell-ducati
//
//  Created by Dimitry Bentsionov on 11/8/12.
//  Copyright (c) 2012 PlayTell. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PTPlaydate.h"
#import "PTPlaymate.h"
#import "PTChatViewController.h"
#import "PTMatchingScoreView.h"
#import "PTMathAvailableCardView.h"
#import "PTMathPairingCardView.h"
#import "PTConnectionLossViewController.h"

@interface PTMathViewController : UIViewController <PTMathGameDelegate> {
    // Game config
    PTPlaydate *playdate;
    NSInteger boardId;
    NSInteger themeId;
    PTPlaymate *initiator;
    PTPlaymate *playmate;
    NSArray *filenames;
    NSInteger totalCards;
    BOOL myTurn;
    NSArray *pairingCards;
    NSArray *availableCards;
    
    // Background shim (used to transition backgrounds)
    UIView *viewBgShim;
    
    // Buttons
    IBOutlet UIButton *endPlaydate;
    
    // Available cards
    UIView *viewAvailableCards;
    UIScrollView *viewAvailableCardsScroll;
    UIView *viewTrackingCard;
    UIImageView *viewTrackingCardImage;
    CGPoint pointTouchOriginal;
    CGPoint pointTouchOffset;
    CGSize sizeTouchOriginal;
    NSInteger currentAvailableIndex;
    PTMathAvailableCardView *viewCurrentAvailableCardView;
    CGFloat heightAvailableCards;
    
    // Pairing cards
    UIView *viewPairingCardsContainer;
    UIView *viewPairingCards;
    CGRect rectLandingStrip;
    BOOL canTrackingCardLand;
    BOOL isTrackingCardSmall;
    BOOL isBoardFlipped;
    NSInteger currentPairingIndex;
    PTMathPairingCardView *viewCurrentPairingCardView;
    BOOL isGameOver;
    NSNumber *winnerId;
    
    // Winner/loser
    UIImageView *winnerView;
    UIImageView *loserView;
    UIImageView *drawView;
    
    // Score views
    PTMatchingScoreView *scoreViewMe;
    PTMatchingScoreView *scoreViewOpponent;
    
    // Shadow wedge
    UIView *viewBottomShawdow;
    
    PTConnectionLossViewController *connectionLossController;
    NSTimer *connectionLossTimer;
    BOOL showingConnectionLossController;
}

@property (nonatomic, strong) PTChatViewController* chatController;

- (id)initWithNibName:(NSString*)nibNameOrNil
               bundle:(NSBundle*)nibBundleOrNil
             playdate:(PTPlaydate *)_playdate
              boardId:(NSInteger)_boardId
              themeId:(NSInteger)_themeId
            initiator:(PTPlaymate *)_initiator
             playmate:(PTPlaymate *)_playmate
            filenames:(NSArray*)_filenames
           totalCards:(NSInteger)_totalCards
          cardsString:(NSString*)_cardsString
               myTurn:(BOOL)_myTurn;

- (IBAction)endGame:(id)sender;

@end