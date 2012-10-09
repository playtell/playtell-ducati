//
//  PTMemoryGameCard.h
//  playtell-ducati
//
//  Created by Giancarlo Daniele on 8/24/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PTMemoryCardCoordinate.h"
#import "PTMemoryGameDelegate.h"

@interface PTMemoryGameCard : NSObject {
    NSInteger boardIndex; // Index in board's card array
    UIButton *card;
    UIImage *back, *front;
    BOOL isBackShown;
    BOOL isCardEnabled;
    CGSize size;
    PTMemoryCardCoordinate *coordinates;
    id<PTMemoryGameDelegate> delegate;
}

@property (nonatomic, retain) UIButton *card;
@property (nonatomic, retain) PTMemoryCardCoordinate *coordinates;
@property (nonatomic) CGSize size;
@property (nonatomic, retain) id<PTMemoryGameDelegate> delegate;

- (id)initWithFrontFilename:(NSString *)front_filename
               backFilename:(NSString *)back_filename
               indexOnBoard:(NSInteger)board_index
              numberOfCards:(NSInteger)num_cards;
- (void)flipCard;
- (void)flipCardDelayed:(BOOL)doDelay;

@end
