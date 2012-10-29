//
//  PTMatchingViewController.h
//  playtell-ducati
//
//  Created by Dimitry Bentsionov on 10/23/12.
//  Copyright (c) 2012 PlayTell. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PTPlaydate.h"
#import "PTPlaymate.h"
#import "PTMatchingAvailableCardView.h"
#import "PTMatchingAvailableCardsView.h"
#import "PTMatchingPairingCardsView.h"

@interface PTMatchingViewController : UIViewController <UIScrollViewDelegate, PTMachingGameDelegate> {
    // Game config
    PTPlaydate *playdate;
    NSInteger boardId;
    NSInteger themeId;
    PTPlaymate *initiator;
    PTPlaymate *playmate;
    NSArray *filenames;
    NSInteger totalCards;
    BOOL myTurn;
    NSArray *cards;
    
    // Background shim (used to transition backgrounds)
    UIView *viewBgShim;
    
    // Buttons
    IBOutlet UIButton *endPlaydate;
    
    // Available cards
    PTMatchingAvailableCardsView *viewAvailableCards;
    UIScrollView *viewAvailableCardsScroll;
    UIView *viewTrackingCard;
    CGPoint pointTouchOriginal;
    CGPoint pointTouchOffset;
    PTMatchingAvailableCardView *viewOriginalTrackingCard;
    
    // Pairing cards
    PTMatchingPairingCardsView *viewPairingCards;
    UIScrollView *viewPairingCardsScroll;
}

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