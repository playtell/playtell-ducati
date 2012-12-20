//
//  PTHangmanViewController.h
//  playtell-ducati
//
//  Created by Dimitry Bentsionov on 12/12/12.
//  Copyright (c) 2012 PlayTell. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PTPlaydate.h"
#import "PTPlaymate.h"
#import "PTChatViewController.h"
#import "PTHangmanDelegate.h"
#import "PTHangmanDrawboard.h"

@interface PTHangmanViewController : UIViewController <PTHangmanDelegate> {
    // Game config
    PTPlaydate *playdate;
    NSInteger boardId;
    PTPlaymate *initiator;
    PTPlaymate *playmate;
    BOOL myTurn;
    NSInteger gameState;
    NSInteger gameWinner;

    // End playdate button
    IBOutlet UIButton *endPlaydate;
    
    // Game state views
    IBOutlet UIView *viewSelectWord;
    IBOutlet UIView *viewSelectLetter;
    IBOutlet UIView *viewDraw;
    IBOutlet UIView *viewWaitForWord;
    IBOutlet UIView *viewWaitForDrawing;
    IBOutlet UIScrollView *letterScrollView;
    
    // Gallows
    UIImageView *viewGallows;
    
    // Word container
    NSMutableArray *wordArray;
    NSMutableArray *wordLetterViews;
    BOOL isAnimatingLetters;
    
    // Guess letters
    NSInteger wordLength;
    NSMutableArray *guessLetterViews;
    BOOL isSelectLetterViewSetup;
    BOOL isFirstTimeGuessing;
    UIImageView *viewSelectLetterImageView;
    
    // Draw
    PTHangmanDrawboard *drawBoard;
    NSMutableArray *drawPoints;
    NSMutableArray *pusherDrawPoints;
    CADisplayLink *frameLink;
    IBOutlet UIButton *drawSomethingButton;
    IBOutlet UIView *drawSomethingButtonContainer;
    IBOutlet UIImageView *drawSomethingMan;
    NSInteger guessAttempts;
    NSInteger maxGuessAttempts;
    
    // Hang
    UIButton *hangButton;
    
    // Winner
    UIImageView *winnerView;
}

@property (nonatomic, strong) PTChatViewController* chatController;

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil
             playdate:(PTPlaydate *)_playdate
              boardId:(NSInteger)_boardId
            initiator:(PTPlaymate *)_initiator
             playmate:(PTPlaymate *)_playmate;

- (IBAction)endGame:(id)sender;

@end