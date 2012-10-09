//
//  PTTictactoeCoordinate.h
//  playtell-ducati
//
//  Created by Giancarlo Daniele on 8/9/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PTTictactoeCoordinate : NSObject

-(id) initWithCoordinateString:(NSString *)coordinates;
-(id) initWithxIndex:(int)x yIndex:(int)y;

@property (nonatomic, readwrite) int xIndex, yIndex;
@property (nonatomic, readwrite) float boardX, boardY;
@property (nonatomic, readwrite) NSString *coordinateString;


@end
