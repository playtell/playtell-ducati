//
//  PTPlaymateFactory.h
//  playtell-ducati
//
//  Created by Ricky Hussmann on 6/2/12.
//  Copyright (c) 2012 PlayTell. All rights reserved.
//

#import "PTPlaymate.h"

#import <Foundation/Foundation.h>

@protocol PTPlaymateFactory <NSObject>
- (PTPlaymate*)playmateWithId:(NSUInteger)playmateId;
- (PTPlaymate*)playmateWithUsername:(NSString*)username;
- (NSArray*)allPlaymates;
@end
