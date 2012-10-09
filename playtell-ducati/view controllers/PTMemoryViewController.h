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
#import "PTMemoryGameBoard.h"


@interface PTMemoryViewController : UIViewController {
    IBOutlet UIButton *endPlaydate;
    
    //communication variables
//    int board_id;
    BOOL board_enabled;
    
    NSArray *board_buttons, *board_turn_indicators;
    NSMutableArray *board_cards;
}

// Board stuff
@property (nonatomic) PTPlaydate *playdate;

// Chat view controller
@property (nonatomic, strong) PTChatViewController* chatController;

@property (nonatomic, strong) PTMemoryGameBoard *board;

//@property (nonatomic) int board_id;

- (id) initializeWithmyTurn:(BOOL)myTurn
                    boardID:(int)board_id
                 playmateID:(int)playmate_id
                initiatorID:(int)initiator_id
               allFilenames:(NSArray *)filenames
                   numCards:(int)num_cards;

- (void)updateUIWithStatus:(int)status
                 card1Index:(int)card1_index
                 card2Index:(int)card2_index
                  winStatus:(int)winStatus
             isCurrentUser:(BOOL)isCurrentUser;

@end