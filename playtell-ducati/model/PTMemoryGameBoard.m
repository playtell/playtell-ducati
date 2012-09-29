//
//  PTMemoryGameBoard.m
//  playtell-ducati
//
//  Created by Giancarlo Daniele on 8/24/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import "PTMemoryGameBoard.h"
#import "PTMemoryGameCard.h"

@implementation PTMemoryGameBoard

NSString *backFilename = @"card-back.png";

@synthesize initiator_id, playmate_id, playdate_id, totalNumCards, cardsLeftOnBoard, cardsOnBoard, isMyTurn, isOneCardAlreadyFlipped;

- (id)initMemoryGameBoardWithNumCards:(int)numCards
                               isMyTurn:(BOOL)myTurn
                               playdate:(int)playdateId
                              initiator:(int)initiatorId
                               playmate:(int)playmateId
                               filenameDict:(NSArray *)allFilenames
{
    //set instance vars
    [self setTotalNumCards:numCards];
    [self setPlaydate_id:playdateId];
    [self setInitiator_id:initiatorId];
    [self setIsMyTurn:myTurn];
    [self setIsOneCardAlreadyFlipped:NO];
    
    [self setCardsOnBoard:[self initializeCardsOnBoard:allFilenames]];
    [self setCardsLeftOnBoard:numCards];

    return self;
}

- (NSMutableArray *)initializeCardsOnBoard:(NSArray *)filenames
{
    NSMutableArray *allCards = [[NSMutableArray alloc] init];
    int count = [filenames count];
    for (int i = 0; i < count; i++) {
        PTMemoryGameCard *card = [[PTMemoryGameCard alloc] initWithFrontFilename:[filenames objectAtIndex:i] backFilename:backFilename indexOnBoard:i];
        [allCards addObject:card];        
    }
    return allCards;
}
                                     

- (void)enableBoard
{

}

- (void)disableBoard
{
    
}

- (void)cardMatch:(int)card1Index
            card2:(int)card2Index

{
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
