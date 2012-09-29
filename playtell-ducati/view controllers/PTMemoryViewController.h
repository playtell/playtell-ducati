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
    IBOutlet UIButton *closeMemory, *card0, *card1, *card2, *card3;
}

// Board stuff
@property (nonatomic, retain) IBOutlet UIButton *closeMemory;

// Chat view controller
@property (nonatomic, strong) PTChatViewController* chatController;

@property (nonatomic, strong) PTMemoryGameBoard *board;

- (id) initializeWithmyTurn:(BOOL)myTurn
                    boardID:(int)board_id
                 playmateID:(int)playmate_id
                initiatorID:(int)initiator_id
               allFilenames:(NSArray *)filenames
                   numCards:(int)num_cards;

@end
