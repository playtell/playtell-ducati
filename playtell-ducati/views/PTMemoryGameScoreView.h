//
//  PTMemoryGameScoreView.h
//  playtell-ducati
//
//  Created by Dimitry Bentsionov on 10/10/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PTMemoryGameScoreView : UIView {
    UIView *frontView;
    UIView *backView;
    UILabel *lblScore;
}

- (void)setScore:(NSInteger)score;
- (void)showYourTurn:(BOOL)isYourTurn delay:(BOOL)doDelay;

@end