//
//  PTTictactoeCoordinate.m
//  playtell-ducati
//
//  Created by Giancarlo Daniele on 8/9/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import "PTTictactoeCoordinate.h"

@implementation PTTictactoeCoordinate

@synthesize xIndex, yIndex, coordinateString, boardX, boardY;

-(id) initWithCoordinateString:(NSString *)coordinates {
    NSMutableString *cs = [NSMutableString stringWithString:@""];
    
    if (coordinates.length < 2) {
        [cs appendString:@"0"];
        [cs appendString:coordinates];
    }
    else {
        [cs appendString:coordinates];
    }
    //if the coordinate string is two characters long, handle it normally
    
    if ([cs length] >= 2) {
        NSString *xDigit = [cs substringToIndex:1];
        self.xIndex = [xDigit floatValue];
        NSString *yDigit = [cs substringWithRange:NSMakeRange(1, 1)];
        self.yIndex = [yDigit floatValue];
        coordinateString = cs;
        
        [self setBoardCoordinates];

    }
    else {
        abort(); //TODOGIANCARLO revisit this, is this really better than an NSException?
    }
    return self;
}

-(id) initWithxIndex:(int)x yIndex:(int)y {
    self.yIndex = y;
    self.xIndex = x;
    
    NSString *coordinates = [NSString stringWithFormat:@"%i%i", x, y];
    
    self.coordinateString = coordinates;
    
    [self setBoardCoordinates];

    return self;
}

- (void)setBoardCoordinates
{
    if ((self.xIndex == 0) && (self.yIndex == 0)) {
        self.boardX = ROW_COORDINATE_0;
        self.boardY = COL_COORDINATE_0;
    }
    if ((self.xIndex == 0) && (self.yIndex == 1)) {
        self.boardX = ROW_COORDINATE_1;
        self.boardY = COL_COORDINATE_0;
    }
    if ((self.xIndex == 0) && (self.yIndex == 2)) {
        self.boardX = ROW_COORDINATE_2;
        self.boardY = COL_COORDINATE_0;
    }
    if ((self.xIndex == 1) && (self.yIndex == 0)) {
        self.boardX = ROW_COORDINATE_0;
        self.boardY = COL_COORDINATE_1;
    }
    if ((self.xIndex == 1) && (self.yIndex == 1)) {
        self.boardX = ROW_COORDINATE_1;
        self.boardY = COL_COORDINATE_1;
    }
    if ((self.xIndex == 1) && (self.yIndex == 2)) {
        self.boardX = ROW_COORDINATE_2;
        self.boardY = COL_COORDINATE_1;
    }
    if ((self.xIndex == 2) && (self.yIndex == 0)) {
        self.boardX = ROW_COORDINATE_0;
        self.boardY = COL_COORDINATE_2;
    }
    if ((self.xIndex == 2) && (self.yIndex == 1)) {
        self.boardX = ROW_COORDINATE_1;
        self.boardY = COL_COORDINATE_2;
    }
    if ((self.xIndex == 2) && (self.yIndex == 2)) {
        self.boardX = ROW_COORDINATE_2;
        self.boardY = COL_COORDINATE_2;
    }
}

@end
