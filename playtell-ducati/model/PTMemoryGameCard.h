//
//  PTMemoryGameCard.h
//  playtell-ducati
//
//  Created by Giancarlo Daniele on 8/24/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PTMemoryGameCard : NSObject
{
    int artwork_index; //id of artwork, used for matching
    int theme_id;
    int boardIndex; //index in board's card array

    UIImageView *faceDown;
    UIImageView *faceUp;
    NSString *faceDownFilename;
    
    BOOL isFaceDown;
    
    float boardX;
    float boardY;
}

@property int artwork_index, boardIndex, theme_id, board_id;

@property float boardX, boardY;
@property BOOL isFaceDown;
@property UIImageView *faceDown, *faceUp;
@property NSString *faceDownFilename;

- (void) initWithTheme:(int)themeId
               artwork:(int)artworkIndex;

- (void) placeOnBoard;

- (void) flip;

- (void) enlarge;

- (void) floatToMiddle; //preceeds stashInDeck

- (void) stashInDeck:(int)player_id;

- (void) shake;

- (void) glow;

- (void) removeFromPlay;

//TODO, figure out notyourturn strategy

@end
