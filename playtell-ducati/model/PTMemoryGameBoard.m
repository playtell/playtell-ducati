//
//  PTMemoryGameBoard.m
//  playtell-ducati
//
//  Created by Giancarlo Daniele on 8/24/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import "PTMemoryGameBoard.h"

@implementation PTMemoryGameBoard

@synthesize theme_id, totalNumCards, cardsLeft, myTurn, initiator_id, playmate_id, cards, playdate_id;

- (void)initMemoryGameBoardWithNumCards:(int)numCards
                        cardOrderString:(NSString *)ordering
                               isMyTurn:(BOOL)isMyTurn
                               playdate:(int)playdateId
                              initiator:(int)initiatorId
                               playmate:(int)playmateId
                                  theme:(int)themeId
{
    //set instance vars
    self.theme_id = themeId;
    self.totalNumCards = numCards;
    self.cardsLeft = numCards;
    self.playmate_id = playmateId;
    self.initiator_id = initiatorId;
    self.playdate_id = playdateId;
    self.myTurn = isMyTurn;
    
    //set up card order visually (also sets board coordinates of each card)
    
    
}

- (void)enableBoard
{

}

- (void)disableBoard
{
    
}

- (void)touchCard:(int)index
{
    //grab card
    
    //flip it
    
    //enlarge it
}

- (void)cardMatch:(int)card1Index
            card2:(int)card2Index

{
    //grab both cards
}

- (void)displayWinner
{
    
}

- (void)displayLoser
{
    
}

- (void)endGame
{
    
}

- (void)suspendGame
{
    
}

@end
