//
//  PTMemoryGameDelegate.h
//  playtell-ducati
//
//  Created by Dimitry Bentsionov on 10/8/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PTMemoryGameDelegate <NSObject>

- (BOOL)memoryGameCardShouldFlip:(NSInteger)index;
- (void)memoryGameCardDidFlip:(NSInteger)index;

@end