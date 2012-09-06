//
//  PTMemoryGameCard.m
//  playtell-ducati
//
//  Created by Giancarlo Daniele on 8/24/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import "PTMemoryGameCard.h"

@implementation PTMemoryGameCard

@synthesize artwork_index, boardIndex, boardX, boardY, isFaceDown, faceDown, faceUp, theme_id, faceDownFilename;

- (void) initWithTheme:(int)themeId
                    artwork:(int)artworkIndex
{
    [self setArtWorkFilenames:themeId artworkIndex:artworkIndex];
    
    [self placeOnBoard];
}

- (void) flip{ }

- (void) enlarge{ }

- (void) floatToMiddle{ } //preceeds stashInDeck

- (void) stashInDeck:(int)player_id{ }

- (void) shake{ }

- (void) glow{ }

- (void) removeFromPlay{ }

- (void) placeOnBoard { }



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
