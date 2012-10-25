//
//  PTMatchingAvailableCardView.h
//  playtell-ducati
//
//  Created by Dimitry Bentsionov on 10/25/12.
//  Copyright (c) 2012 PlayTell. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PTMachingGameDelegate;

@interface PTMatchingAvailableCardView : UIView {
    NSInteger cardIndex;
    UIView *childView;
    id<PTMachingGameDelegate> delegate;
}

@property (nonatomic, retain) id<PTMachingGameDelegate> delegate;

- (id)initWithFrame:(CGRect)frame cardIndex:(NSInteger)_cardIndex;
- (void)setFocusLevel:(CGFloat)focus;

@end

@protocol PTMachingGameDelegate <NSObject>
//- (void)matchingGameAvailableCardDidTouch:(PTMatchingAvailableCardView *)cardView;
- (void)matchingGameAvailableCardTouchesBegan:(PTMatchingAvailableCardView *)cardView touch:(UITouch *)touch;
- (void)matchingGameAvailableCardTouchesMoved:(PTMatchingAvailableCardView *)cardView touch:(UITouch *)touch;
- (void)matchingGameAvailableCardTouchesEnded:(PTMatchingAvailableCardView *)cardView touch:(UITouch *)touch;
- (void)matchingGameAvailableCardTouchesCancelled:(PTMatchingAvailableCardView *)cardView touch:(UITouch *)touch;
@end