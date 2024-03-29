//
//  PTTictactoeViewController.h
//  playtell-ducati
//
//  Created by Giancarlo Daniele on 7/28/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "PTChatViewController.h"
#import "PTPagesScrollView.h"
#import "PTPlaydate.h"

@interface PTTictactoeViewController : UIViewController {
    
    // Playdate buttons
    PTPlaydate *playdate;
    IBOutlet UIButton *closeTictactoe;
    IBOutlet UIView *endPlaydatePopup;

    //tic tac toe specific
    IBOutlet UIButton *space00, *space01, *space02, *space10, *space11, *space12, *space20, *space21, *space22;
    
    //communication variables
    int whose_turn, board_id;
    BOOL board_enabled;
    BOOL isMyTurn;
    
    NSArray *board_buttons, *turn_indicators;
    NSMutableArray *board_spaces;

    // Tooltip
    UIImageView *ttWaitYourTurn;
}

//playdate specific
@property (nonatomic) PTPlaydate *playdate;
@property (nonatomic, retain) IBOutlet UIButton *endPlaydate;
@property (nonatomic, retain) IBOutlet UIButton *endPlaydateForreal;
@property (nonatomic, retain) IBOutlet UIView *endPlaydatePopup, *blackScreen;
@property (nonatomic, retain) UIImageView *board;

//tic tac toe specific
@property (nonatomic, retain) IBOutlet UIButton *space00, *space01, *space02, *space10, *space11, *space12, *space20, *space21, *space22, *closeTictactoe;
@property (nonatomic) NSInteger board_id, initiator_id, playmate_id;

// Chat view controller
@property (nonatomic, strong) PTChatViewController* chatController;

//tic tac toe specific methods
- (IBAction)endGame:(id)sender;
- (IBAction)placePiece:(id)sender;
- (void)initGameWithMyTurn:(BOOL)myTurn;

@end
