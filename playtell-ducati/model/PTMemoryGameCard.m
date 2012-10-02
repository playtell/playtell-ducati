//
//  PTMemoryGameCard.m
//  playtell-ducati
//
//  Created by Giancarlo Daniele on 8/24/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import "PTMemoryGameCard.h"
#import "PTMemoryCardCoordinate.h"
#import "PTAppDelegate.h"
#import "UIImageView+Animations.h"

// ## PTMemoryCard class encompasses a single card object on the board. "boardIndex" is what's used by the rails backend to determine whether or not two selected cards have been matched. The "front" of the card, as referred to in code, is the side of the card that contains the artwork, the "back" is not unique.
@implementation PTMemoryGameCard

@synthesize boardIndex, coordinates, cardHeight, cardWidth, isBackUp, cardDisabled, card, front, back;

- (id) initWithFrontFilename:(NSString *)front_filename
                  backFilename:(NSString *)back_filename
                    indexOnBoard:(int)board_index
               numberOfCards:(int)num_cards
{
    //create "card" UIBUtton
    [self setCard:[UIButton buttonWithType:UIButtonTypeCustom]];
    [self setBack:[UIImage imageNamed:back_filename]];
    [self setFront:[UIImage imageNamed:front_filename]];
    [[self card] setBackgroundImage:[self back] forState:UIControlStateNormal];
    
    [[self card] addTarget:self action:@selector(cardTouched:) forControlEvents:UIControlEventTouchUpInside];
    
    [[self card] setTag:board_index];
        
    //set up the card object
    [self setBoardIndex:board_index];
    [self setIsBackUp:YES];
      
    //set these based on the num cards
    [self setCardWidth:164];
    [self setCardHeight:225];
    if (num_cards == 12) {
        [self setCardWidth:128];
        [self setCardHeight:179];
    }

    //set coordinates
    [self setCardWidth:[self cardWidth]];
    [self setCardHeight:[self cardHeight]];
    [self setCoordinates:[[PTMemoryCardCoordinate alloc] initWithNumCards:num_cards index:[self boardIndex]]];
    
    return self;
}

- (void)flipCardAnimation
{
    UIImage *otherSideImage;
    otherSideImage = (self.isBackUp) ? self.front : self.back;
    
    [UIView transitionWithView:self.card
                      duration:0.5f
                       options:UIViewAnimationOptionTransitionFlipFromLeft
                    animations:^{
                        [[self card] setBackgroundImage:otherSideImage forState:UIControlStateNormal];
                    }
                    completion:^(BOOL finished){
                        [[self card] setBackgroundImage:otherSideImage forState:UIControlStateNormal];
                    }];
    ([self isBackUp]) ? [self setIsBackUp:NO] : [self setIsBackUp:YES];
}

// ## GAMEPLAY METHODS START ##
- (IBAction)cardTouched:(id)sender
{
    PTAppDelegate* appDelegate = (PTAppDelegate*)[[UIApplication sharedApplication] delegate];
    [[[appDelegate memoryViewController] board] playTurn:self];
    [self flipCardAnimation];
}



@end
