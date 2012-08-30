//
//  PTMemoryGameBoard.h
//  playtell-ducati
//
//  Created by Giancarlo Daniele on 8/24/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PTMemoryGameBoard : NSObject
{
    int theme_id; //e.g. safari theme, halloween theme
    
    int totalNumCards; //TODO make method that utilizes this
    int cardsLeft; //TODO do we need this? maybe server can take care of it
    BOOL myTurn;
    int initiator_id;
    int playmate_id;
    int playdate_id;
    
    NSMutableArray *cards;
}

@property int theme_id, totalNumCards, cardsLeft, initiator_id, playmate_id, playdate_id;
@property NSMutableArray *cards;
@property BOOL myTurn;

- (void)initMemoryGameBoardWithNumCards:(int)numCards
                        cardOrderString:(NSString *)ordering
                               isMyTurn:(BOOL)isMyTurn
                               playdate:(int)playdateId
                              initiator:(int)initiatorId
                               playmate:(int)playmateId
                                  theme:(int)themeId;

- (void)enableBoard;

- (void)disableBoard;

- (void)touchCard:(int)index;

- (void)cardMatch:(int)card1Index card2:(int)card2Index;

- (void)displayWinner;

- (void)displayLoser;

- (void)endGame;

- (void)suspendGame;

@end
