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
    BOOL isMyTurn, isOneCardAlreadyFlipped;
    int initiator_id, playmate_id, playdate_id, totalNumCards, cardsLeftOnBoard;
    
    NSMutableArray *cardsOnBoard;
}

@property int initiator_id, playmate_id, playdate_id, totalNumCards, cardsLeftOnBoard;
@property NSMutableArray *cardsOnBoard;
@property BOOL isMyTurn, isOneCardAlreadyFlipped;

- (void)initMemoryGameBoardWithNumCards:(int)numCards
                               isMyTurn:(BOOL)isMyTurn
                               playdate:(int)playdateId
                              initiator:(int)initiatorId
                               playmate:(int)playmateId;

- (NSMutableArray *)initializeCardsOnBoardWithOrderString;

- (void)enableBoard;

- (void)disableBoard;

- (void)touchCard:(int)index;

- (void)cardMatch:(int)card1Index card2:(int)card2Index;

- (void)displayWinner;

- (void)displayLoser;

- (void)endGame;

- (void)suspendGame;

@end
