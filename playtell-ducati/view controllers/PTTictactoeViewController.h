//
//  PTTictactoeViewController.h
//  playtell-ducati
//
//  Created by Giancarlo Daniele on 7/28/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "PTPageView.h"
#import "PTBookView.h"
#import "PTBooksScrollView.h"
#import "PTBooksParentView.h"
#import "PTChatViewController.h"
#import "PTPagesScrollView.h"
#import "PTPlaydate.h"

//TODOGIANCARLO code cleanup here

@interface PTTictactoeViewController : UIViewController <UIScrollViewDelegate, PTBookViewDelegate, PTPagesScrollViewDelegate> {
    
    // Playdate buttons
    PTPlaydate *playdate;
    IBOutlet UIButton *endPlaydate;
    IBOutlet UIButton *closeTictactoe;
    IBOutlet UIButton *endPlaydateForreal;
    IBOutlet UIView *endPlaydatePopup;

    //tic tac toe specific
    IBOutlet UILabel *whichButton, *playmate_id_label, *initiator_id_label, *whose_turn_label, *playdate_id_label, *board_id_label, *game_over_label, *success_label, *opponent_turn_label, *placement_status_label;
    IBOutlet UIButton *space00, *space01, *space02, *space10, *space11, *space12, *space20, *space21, *space22, *animateX, *animateO, *opponentTurnButton;
    
    //communication variables
    NSInteger pieces_placed;
    NSInteger whose_turn;
    BOOL board_enabled;
    BOOL opponent_turn;
    UIImageView *myPiece, *opponentPiece; // TODOGIANCARLO initialize these guys
    NSArray *board_buttons, *turnIndicators;
    NSMutableArray *board_spaces;

}

//playdate specific
@property (nonatomic) PTPlaydate *playdate;
@property (nonatomic, retain) IBOutlet UIButton *endPlaydate;
@property (nonatomic, retain) IBOutlet UIButton *endPlaydateForreal;
@property (nonatomic, retain) IBOutlet UIView *endPlaydatePopup;

//tic tac toe specific
@property (nonatomic, retain) IBOutlet UIButton *space00, *space01, *space02, *space10, *space11, *space12, *space20, *space21, *space22, *closeTictactoe;
@property (nonatomic) NSInteger board_id, initiator_id, playmate_id;  // TODOGIANCARLO figure out if BOOL is the right thing i want here, also discuss use of nonatomic and retain

// Chat view controller
@property (nonatomic, strong) PTChatViewController* chatController;

//tic tac toe specific methods
- (IBAction)endGame:(id)sender; //TODOGIANCARLO implement this
- (IBAction)placePiece:(id)sender;
- (void)initGameWithMyTurn:(BOOL)myTurn;

//playdate specific methods
- (IBAction)playdateDisconnect:(id)sender;
- (IBAction)endPlaydatePopupToggle:(id)sender;

@end
