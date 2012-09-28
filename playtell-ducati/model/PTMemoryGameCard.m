//
//  PTMemoryGameCard.m
//  playtell-ducati
//
//  Created by Giancarlo Daniele on 8/24/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import "PTMemoryGameCard.h"
#import "PTMemoryCardCoordinate.h"

// ## PTMemoryCard class encompasses a single card object on the board. "boardIndex" is what's used by the rails backend to determine whether or not two selected cards have been matched. The "front" of the card, as referred to in code, is the side of the card that contains the artwork, the "back" is not unique.
@implementation PTMemoryGameCard

@synthesize boardIndex, coordinates, cardHeight, cardWidth, isBackUp, cardDisabled, card, front, back;

- (void) initWithFrontFilename:(NSString *)front_filename
                  backFilename:(NSString *)back_filename
                    indexOnBoard:(int)board_index
                   boardX:(float)board_x
                   boardY:(float)board_y
                   cardWidth:(float)card_width
                   cardHeight:(float)card_height
{
    //create "card" UIBUtton
    [self setCard:[UIButton buttonWithType:UIButtonTypeCustom]];
    [self setBack:[UIImage imageNamed:back_filename]];
    [self setFront:[UIImage imageNamed:front_filename]];
    
    [[self card] setBackgroundImage:[self back] forState:UIControlStateNormal];
    
    [[self card] addTarget:self action:@selector(cardTouched:) forControlEvents:UIControlEventTouchUpInside];
        
    //set up the card object
    [self setBoardIndex:board_index];
//    [self setCoordinates:[[PTMemoryCardCoordinate alloc] initWithNumCards:<#(int)#> index:<#(int)#>
    [self setBoardY:board_y];
    [self setCardWidth:card_width];
    [self setCardHeight:card_height];
    [self setIsBackUp:YES];
    [[self card] setFrame:CGRectMake([self boardX], [self boardY], [self cardWidth], [self cardHeight])];    
}

- (void) flip
{
}

- (void) enlarge
{
    
}

- (void) floatToMiddle
{
    
} //preceeds stashInDeck

- (void) stashInDeck:(int)player_id
{
    
}

- (void) shake
{
    
}

- (void) glow
{
    
}

- (void) removeFromPlay
{
    
}

- (void) cardTouched
{
    
}

// # START HELPER METHODS #
// # setters #
- (void) setBoardCoordinates:(int)boardIndex
numCards:(int)totalCards
{
    
}

- (void) setArtWorkFilenames:(int)themeId
artworkIndex:(int)artworkIndex
{
    
}

@end
