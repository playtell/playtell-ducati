//
//  PTMemoryGameCard.h
//  playtell-ducati
//
//  Created by Giancarlo Daniele on 8/24/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PTMemoryCardCoordinate.h"

@interface PTMemoryGameCard : NSObject
{
    int boardIndex; //index in board's card array
    UIButton *card;
    UIImage *back, *front;
    BOOL isBackUp, cardDisabled; //cards are disabled once they form part of a match
    float boardX,boardY;
    float cardWidth, cardHeight;
    PTMemoryCardCoordinate *coordinates;
}

@property int boardIndex;
@property float boardX, boardY, cardWidth, cardHeight;
@property BOOL isBackUp, cardDisabled;
@property UIButton *card;
@property UIImage *back, *front;
@property PTMemoryCardCoordinate *coordinates;

- (void) initWithFrontFilename:(NSString *)front_filename
                  backFilename:(NSString *)back_filename
                  indexOnBoard:(int)board_index
                        boardX:(float)board_x
                        boardY:(float)board_y
                     cardWidth:(float)card_width
                    cardHeight:(float)card_height;

- (void) flip;

- (void) enlarge;

- (void) floatToMiddle; //preceeds stashInDeck

- (void) stashInDeck:(int)player_id;

- (void) shake;

- (void) glow;

- (void) removeFromPlay;

//TODO, figure out notyourturn strategy

@end
