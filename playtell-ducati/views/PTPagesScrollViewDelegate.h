//
//  PTPagesScrollViewDelegate.h
//  playtell-ducati
//
//  Created by Dimitry Bentsionov on 6/14/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

@protocol PTPagesScrollViewDelegate
@optional
- (void)pageTurnedTo:(NSInteger)number;
- (void)pageLoaded:(NSInteger)number;
- (void)bookPinchClose;
- (void)fingerTouchStartedAtPoint:(CGPoint)point;
- (void)fingerTouchEndedAtPoint:(CGPoint)point;
@end