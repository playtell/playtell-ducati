//
//  PTMemoryGameCard.m
//  playtell-ducati
//
//  PTMemoryCard class encompasses a single card object on the board. "boardIndex" is
//  what's used by the rails backend to determine whether or not two selected cards have
//  been matched. The "front" of the card, as referred to in code, is the side of the card
//  that contains the artwork, the "back" is not unique.
//
//  Created by Giancarlo Daniele on 8/24/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import "PTMemoryGameCard.h"

@implementation PTMemoryGameCard

@synthesize card;
@synthesize coordinates;
@synthesize size;
@synthesize delegate;

- (id)initWithFrontFilename:(NSString *)front_filename
               backFilename:(NSString *)back_filename
               indexOnBoard:(NSInteger)board_index
              numberOfCards:(NSInteger)num_cards {

    // Card UIButton
    card = [UIButton buttonWithType:UIButtonTypeCustom];
    back = [UIImage imageNamed:back_filename];
    front = [UIImage imageNamed:front_filename];
    [card setBackgroundImage:back forState:UIControlStateNormal];
    [card addTarget:self action:@selector(cardTouched:) forControlEvents:UIControlEventTouchUpInside];
    [card setTag:board_index];

    // Setup the card object
    boardIndex = board_index;
    isBackShown = YES;
    isCardEnabled = YES;

    // Set these based on the num cards
    if (num_cards == 12) {
        size = CGSizeMake(128.0f, 179.0f);
    } else {
        size = CGSizeMake(164.0f, 225.0f);
    }

    // Setup card coordinates
    coordinates = [[PTMemoryCardCoordinate alloc] initWithNumCards:num_cards
                                                             index:boardIndex];
    return self;
}

- (void)flipCard {
    UIImage *otherSideImage = isBackShown ? front : back;
    
    [UIView transitionWithView:card
                      duration:0.5f
                       options:UIViewAnimationOptionTransitionFlipFromLeft
                    animations:^{
                        [card setBackgroundImage:otherSideImage forState:UIControlStateNormal];
                    }
                    completion:^(BOOL finished){
                        [card setBackgroundImage:otherSideImage forState:UIControlStateNormal];
                    }];

    isBackShown = !isBackShown;
}

- (void)flipCardDelayed:(BOOL)doDelay {
    if (doDelay == YES) {
        [self performSelector:@selector(flipCard) withObject:nil afterDelay:1.0f];
    } else {
        [self flipCard];
    }
}

- (IBAction)cardTouched:(id)sender {
    // Are we allowed to flip the card?
    if ([self.delegate memoryGameCardShouldFlip:boardIndex] == YES) {
        // Flip the card
        [self flipCard];
        
        // Notify delegate
        [self.delegate memoryGameCardDidFlip:boardIndex];
    }
}

@end