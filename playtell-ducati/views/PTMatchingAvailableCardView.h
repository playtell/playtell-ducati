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
    UIImageView *childView;
    UIView *borderView;
    id<PTMachingGameDelegate> delegate;
}

@property (nonatomic, retain) id<PTMachingGameDelegate> delegate;

- (id)initWithFrame:(CGRect)frame cardIndex:(NSInteger)_cardIndex delegate:(id<PTMachingGameDelegate>)_delegate;
- (void)setFocusLevel:(CGFloat)focus;
- (NSInteger)getCardIndex;
- (UIImage*)getCardImage;

@end

@protocol PTMachingGameDelegate <NSObject>
- (void)matchingGameAvailableCardTouchesBegan:(PTMatchingAvailableCardView *)cardView touch:(UITouch *)touch;
- (void)matchingGameAvailableCardTouchesMoved:(PTMatchingAvailableCardView *)cardView touch:(UITouch *)touch;
- (void)matchingGameAvailableCardTouchesEnded:(PTMatchingAvailableCardView *)cardView touch:(UITouch *)touch;
- (void)matchingGameAvailableCardTouchesCancelled:(PTMatchingAvailableCardView *)cardView touch:(UITouch *)touch;
- (UIImage*)matchingGameImageForCardIndex:(NSInteger)cardIndex;
- (void)matchingGamePairingCardDidFinishUpDownAnimation;
- (void)matchingGamePairingCardDidFinishLeftRightAnimation;
@end