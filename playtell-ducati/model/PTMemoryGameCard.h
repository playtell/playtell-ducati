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
    float cardWidth, cardHeight;
    PTMemoryCardCoordinate *coordinates;
}

@property int boardIndex;
@property float cardWidth, cardHeight;
@property BOOL isBackUp, cardDisabled;
@property UIButton *card;
@property UIImage *back, *front;
@property PTMemoryCardCoordinate *coordinates;

- (id) initWithFrontFilename:(NSString *)front_filename
                backFilename:(NSString *)back_filename
                indexOnBoard:(int)board_index
               numberOfCards:(int)num_cards;

@end
