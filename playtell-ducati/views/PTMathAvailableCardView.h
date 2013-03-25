//
//  PTMathAvailableCardView.h
//  playtell-ducati
//
//  Created by Dimitry Bentsionov on 11/12/12.
//  Copyright (c) 2012 PlayTell. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PTMathGameDelegate;

@interface PTMathAvailableCardView : UIView {
    NSInteger cardIndex;
    UIImageView *childView;
    id<PTMathGameDelegate> delegate;
    UIImage *cardImage;
}

@property (nonatomic, retain) id<PTMathGameDelegate> delegate;

- (id)initWithFrame:(CGRect)frame cardIndex:(NSInteger)_cardIndex delegate:(id<PTMathGameDelegate>)_delegate;
- (NSInteger)getCardIndex;
- (UIImage*)getCardImage;
- (void)setCardImage:(UIImage *)image;

@end

@protocol PTMathGameDelegate <NSObject>
- (void)mathGameAvailableCardTapped:(PTMathAvailableCardView *)cardView;
- (void)mathGameAvailableCardTouchesBegan:(PTMathAvailableCardView *)cardView touch:(UITouch *)touch;
- (void)mathGameAvailableCardTouchesMoved:(PTMathAvailableCardView *)cardView touch:(UITouch *)touch;
- (void)mathGameAvailableCardTouchesEnded:(PTMathAvailableCardView *)cardView touch:(UITouch *)touch;
- (void)mathGameAvailableCardTouchesCancelled:(PTMathAvailableCardView *)cardView touch:(UITouch *)touch;
- (UIImage*)mathGameImageForCardIndex:(NSInteger)cardIndex;
- (void)mathGamePairingCardDidFinishUpDownAnimation;
- (void)mathGamePairingCardDidFinishLeftRightAnimation;
@end