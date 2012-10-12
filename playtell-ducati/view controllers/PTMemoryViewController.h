//
//  PTMemoryViewController.h
//  playtell-ducati
//
//  Created by Giancarlo D on 9/16/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PTChatViewController.h"
#import "PTPlaydate.h"
#import "PTMemoryGameDelegate.h"
#import "PTMemoryGameScoreView.h"

@interface PTMemoryViewController : UIViewController <PTMemoryGameDelegate> {
    // Game data
    PTPlaydate *playdate;
    NSInteger boardID;
    NSInteger playmateID;
    NSInteger initiatorID;
    NSArray *filenames;
    NSInteger numCards;
    BOOL isMyTurn;

    // End playdate button
    IBOutlet UIButton *endPlaydate;
    
    NSArray *board_buttons;
    NSArray *turn_indicators;
    NSMutableArray *cards;
    
    // Card indices
    NSNumber *cardIndex1;
    NSNumber *cardIndex2;
    
    // Sounds
    AVAudioPlayer* soundWin;
    AVAudioPlayer* soundLoss;
    AVAudioPlayer* soundMiss;
    
    // Score
    IBOutlet PTMemoryGameScoreView *scoreViewMe;
    IBOutlet PTMemoryGameScoreView *scoreViewOpponent;
    
    // Tooltip
    UIImageView *ttWaitYourTurn;
    
    // Winner/loser
    UIImageView *winnerView;
    UIImageView *loserView;
}

@property (nonatomic, strong) PTChatViewController* chatController;

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil
             playdate:(PTPlaydate *)_playdate
               myTurn:(BOOL)myTurn
              boardID:(NSInteger)_boardID
           playmateID:(NSInteger)_playmateID
          initiatorID:(NSInteger)_initiatorID
         allFilenames:(NSArray *)_filenames
             numCards:(NSInteger)_numCards;

//- (void)updateUIWithStatus:(int)status
//                 card1Index:(int)card1_index
//                 card2Index:(int)card2_index
//                  winStatus:(int)winStatus
//             isCurrentUser:(BOOL)isCurrentUser;

@end