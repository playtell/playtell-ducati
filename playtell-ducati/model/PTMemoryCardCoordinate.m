//
//  PTMemoryCardCoordinate.m
//  playtell-ducati
//
//  Created by Giancarlo D on 9/28/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import "PTMemoryCardCoordinate.h"

@implementation PTMemoryCardCoordinate


@synthesize index, numCards, boardX, boardY;


-(id) initWithNumCards:(int)numberCards index:(int)the_index {
    self.index = the_index;
    self.numCards = numberCards;
    
    [self setBoardCoordinates];
    
    return self;
}

- (void)setBoardCoordinates
{
    if (self.numCards == 8) {
        if (self.index == 0) {
            self.boardX = 96;
            self.boardY = 130;
        }
        if (self.index == 1) {
            self.boardX = 330;
            self.boardY = 130;
        }
        if (self.index == 2) {
            self.boardX = 541;
            self.boardY = 130;
        }
        if (self.index == 3) {
            self.boardX = 758;
            self.boardY = 130;
        }
        if (self.index == 4) {
            self.boardX = 96;
            self.boardY = 406;
        }
        if (self.index == 5) {
            self.boardX = 330;
            self.boardY = 406;
        }
        if (self.index == 6) {
            self.boardX = 541;
            self.boardY = 406;
        }
        if (self.index == 7) {
            self.boardX = 758;
            self.boardY = 406;
        }
    }
    //TODO add support for different number of cards here
}


@end
