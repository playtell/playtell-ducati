//
//  PTMemoryCardCoordinate.h
//  playtell-ducati
//
//  Created by Giancarlo D on 9/28/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PTMemoryCardCoordinate : NSObject

- (id)initWithNumCards:(int)numberCards index:(int)the_index;

@property (nonatomic, readwrite) int index, numCards, boardX, boardY;

@end