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

- (id)initWithNumCards:(int)numberCards index:(int)the_index {
    self.index = the_index;
    self.numCards = numberCards;
    
    [self setBoardCoordinates];
    
    return self;
}

- (void)setBoardCoordinates {
    if (self.numCards == 4) {
        if (self.index == 0) {
            self.boardX = 96;
            self.boardY = 265;
        }
        if (self.index == 1) {
            self.boardX = 330;
            self.boardY = 265;
        }
        if (self.index == 2) {
            self.boardX = 541;
            self.boardY = 265;
        }
        if (self.index == 3) {
            self.boardX = 758;
            self.boardY = 265;
        }
    }
    if (self.numCards == 6) {
        if (self.index == 0) {
            self.boardX = 96;
            self.boardY = 170;
        }
        if (self.index == 1) {
            self.boardX = 429;
            self.boardY = 170;
        }
        if (self.index == 2) {
            self.boardX = 758;
            self.boardY = 170;
        }
        if (self.index == 3) {
            self.boardX = 96;
            self.boardY = 446;
        }
        if (self.index == 4) {
            self.boardX = 429;
            self.boardY = 446;
        }
        if (self.index == 5) {
            self.boardX = 758;
            self.boardY = 446;
        }
    }
    if (self.numCards == 8) {
        if (self.index == 0) {
            self.boardX = 96;
            self.boardY = 170;
        }
        if (self.index == 1) {
            self.boardX = 330;
            self.boardY = 170;
        }
        if (self.index == 2) {
            self.boardX = 541;
            self.boardY = 170;
        }
        if (self.index == 3) {
            self.boardX = 758;
            self.boardY = 170;
        }
        if (self.index == 4) {
            self.boardX = 96;
            self.boardY = 446;
        }
        if (self.index == 5) {
            self.boardX = 330;
            self.boardY = 446;
        }
        if (self.index == 6) {
            self.boardX = 541;
            self.boardY = 446;
        }
        if (self.index == 7) {
            self.boardX = 758;
            self.boardY = 446;
        }
    }
    if (self.numCards == 10) {
        if (self.index == 0) {
            self.boardX = 76;
            self.boardY = 172;
        }
        if (self.index == 1) {
            self.boardX = 254;
            self.boardY = 172;
        }
        if (self.index == 2) {
            self.boardX = 432;
            self.boardY = 172;
        }
        if (self.index == 3) {
            self.boardX = 610;
            self.boardY = 172;
        }
        if (self.index == 4) {
            self.boardX = 788;
            self.boardY = 172;
        }
        if (self.index == 5) {
            self.boardX = 76;
            self.boardY = 443;
        }
        if (self.index == 6) {
            self.boardX = 254;
            self.boardY = 443;
        }
        if (self.index == 7) {
            self.boardX = 432;
            self.boardY = 443;
        }
        if (self.index == 8) {
            self.boardX = 610;
            self.boardY = 443;
        }
        if (self.index == 9) {
            self.boardX = 788;
            self.boardY = 443;
        }
    }
    if (self.numCards == 12) {
        if (self.index == 0) {
            self.boardX = 64;
            self.boardY = 190;
        }
        if (self.index == 1) {
            self.boardX = 220;
            self.boardY = 190;
        }
        if (self.index == 2) {
            self.boardX = 379;
            self.boardY = 190;
        }
        if (self.index == 3) {
            self.boardX = 535;
            self.boardY = 190;
        }
        if (self.index == 4) {
            self.boardX = 683;
            self.boardY = 190;
        }
        if (self.index == 5) {
            self.boardX = 832;
            self.boardY = 190;
        }
        if (self.index == 6) {
            self.boardX = 64;
            self.boardY = 404;
        }
        if (self.index == 7) {
            self.boardX = 220;
            self.boardY = 404;
        }
        if (self.index == 8) {
            self.boardX = 379;
            self.boardY = 404;
        }
        if (self.index == 9) {
            self.boardX = 535;
            self.boardY = 404;
        }
        if (self.index == 10) {
            self.boardX = 683;
            self.boardY = 404;
        }
        if (self.index == 11) {
            self.boardX = 832;
            self.boardY = 404;
        }
    }
}

@end