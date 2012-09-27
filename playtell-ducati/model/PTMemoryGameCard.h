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
    int artworkIndex; //id of artwork, used for matching
    int themeId;
    int boardId;
    int boardIndex; //index in board's card array

    UIButton *card;
    
    NSString *artworkFilename;
    
    BOOL isFaceDown;
    
    float boardX;
    float boardY;    
}

@property int artworkIndex, boardIndex, themeId, boardId;

@property float boardX, boardY;

@property BOOL isFaceDown;

@property UIButton *card;
@property NSString *artworkFilename;

- (void) initWithTheme:(int)theme_id
               artwork:(int)artworkNumber
          indexOnBoard:(int)index;

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
