//
//  PTMemoryGameCard.m
//  playtell-ducati
//
//  Created by Giancarlo Daniele on 8/24/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import "PTMemoryGameCard.h"

@implementation PTMemoryGameCard

@synthesize artworkIndex, boardIndex, themeId, boardId, boardX, boardY, isFaceDown, card, artworkFilename;

- (void) initWithTheme:(int)theme_id
                    artwork:(int)artworkNumber
                    indexOnBoard:(int)index
{
    //to initialize card set isFacedown flag
    self.isFaceDown = true;
    
    //set the filename for the bottom artwork
    [self setArtWorkFilenames:theme_id artworkIndex:artworkNumber];
    
    //give the card a notion of where it is on the board
    self.boardIndex = index;
    
    
    
    [self placeOnBoard];
}

- (void) placeOnBoard
{
    
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
