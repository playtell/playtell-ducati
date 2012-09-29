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

// ## PTMemoryCard class encompasses a single card object on the board. "boardIndex" is what's used by the rails backend to determine whether or not two selected cards have been matched. The "front" of the card, as referred to in code, is the side of the card that contains the artwork, the "back" is not unique.
@implementation PTMemoryGameCard

@synthesize boardIndex, coordinates, cardHeight, cardWidth, isBackUp, cardDisabled, card, front, back;

- (id) initWithFrontFilename:(NSString *)front_filename
                  backFilename:(NSString *)back_filename
                    indexOnBoard:(int)board_index
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
    
    PTAppDelegate* appDelegate = (PTAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    int numCards = [[[appDelegate memoryViewController] board] totalNumCards];
      
    //set these based on the num cards
    [self setCardWidth:164];
    [self setCardHeight:225];
    if (numCards == 12) {
        [self setCardWidth:128];
        [self setCardHeight:179];
    }

    //set coordinates
    [self setCardWidth:[self cardWidth]];
    [self setCardHeight:[self cardHeight]];
    [self setCoordinates:[[PTMemoryCardCoordinate alloc] initWithNumCards:numCards index:[self boardIndex]]];
    
    //set frame for UIButton
    [[self card] setFrame:CGRectMake([[self coordinates] boardX], [[self coordinates] boardY], [self cardWidth], [self cardHeight])];

    return self;
                          
}



@end
