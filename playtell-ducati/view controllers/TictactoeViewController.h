//
//  TictactoeViewController.h
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
#import "PTPagesScrollView.h"
#import "PTPlaydate.h"

@interface TictactoeViewController : UIViewController <UIScrollViewDelegate, PTBookViewDelegate, PTPagesScrollViewDelegate> {
    
    // Playdate buttons
    PTPlaydate *playdate;
    IBOutlet UIButton *endPlaydate;
    IBOutlet UIButton *closeTictactoe;
    IBOutlet UIButton *endPlaydateForreal;
    IBOutlet UIView *endPlaydatePopup;

    //tic tac toe specific
    IBOutlet UILabel *whichButton, *playmate_id_label, *initiator_id_label, *whose_turn_label, *playdate_id_label, *board_id_label;
    IBOutlet UIButton *space00, *space01, *space02, *space10, *space11, *space12, *space20, *space21, *space22, *animateX, *animateO;
    
    //communication variables
    NSInteger pieces_placed;
    NSInteger whose_turn;
    BOOL board_enabled;
    UIImageView *myPiece, *myPieceAnimated, *myPieceFaded; // TODOGIANCARLO initialize these guys
    
    UIImageView *xAnimated, *xStatic, *yAnimated, *yStatic; 
}

//playdate specific
@property (nonatomic) PTPlaydate *playdate;
@property (nonatomic, retain) IBOutlet UIButton *endPlaydate;
@property (nonatomic, retain) IBOutlet UIButton *endPlaydateForreal;
@property (nonatomic, retain) IBOutlet UIView *endPlaydatePopup, *yourTurnIndicator, *yourOpponentsTurnIndicator;

//tic tac toe specific
@property (nonatomic, retain) IBOutlet UIButton *space00, *space01, *space02, *space10, *space11, *space12, *space20, *space21, *space22, *closeTictactoe;
@property (nonatomic) NSInteger board_id, initiator_id, playmate_id;  // TODOGIANCARLO figure out if BOOL is the right thing i want here, also discuss use of nonatomic and retain

//tictactoe testing specific
@property (nonatomic, retain) IBOutlet UIButton *animateX;
@property (nonatomic, retain) IBOutlet UIButton *animateO;

//tic tac toe specific methods
- (IBAction)endGame:(id)sender; //TODOGIANCARLO implement this
- (IBAction)placePiece:(id)sender;
- (void)initGameWithMyTurn:(BOOL)myTurn;

//playdate specific methods
- (IBAction)playdateDisconnect:(id)sender;
- (IBAction)endPlaydatePopupToggle:(id)sender;
- (IBAction)animationStartX:(id)sender;
- (IBAction)animationStartO:(id)sender;

@end
