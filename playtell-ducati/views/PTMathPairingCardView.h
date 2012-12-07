//
//  PTMathPairingCardView.h
//  playtell-ducati
//
//  Created by Dimitry Bentsionov on 11/12/12.
//  Copyright (c) 2012 PlayTell. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PTMathAvailableCardView.h"

@interface PTMathPairingCardView : UIView {
    NSInteger cardIndex;
    id<PTMathGameDelegate> delegate;
    UIImageView *viewCardLeft;
    UIImageView *viewCardRight;
    UIImageView *viewCardPlaceholder;
    NSInteger animationCount;
    BOOL isCardMatched;
    BOOL matchedByMe;
}

@property (nonatomic, retain) id<PTMathGameDelegate> delegate;

- (id)initWithFrame:(CGRect)frame cardIndex:(NSInteger)_cardIndex delegate:(id<PTMathGameDelegate>)_delegate;
- (NSInteger)getCardIndex;
- (void)setEmptyCardViewWithImage:(UIImage*)image matchedByMe:(BOOL)_matchedByMe;
- (void)resetEmptyCardView;
- (void)jumpUpDownDelayed:(BOOL)doDelay;
- (void)jumpUpDown;
- (void)jumpLeftRightDelayed:(BOOL)doDelay;
- (void)jumpLeftRight;
- (void)setLandingZoneAsActive;
- (void)setLandingZoneAsInactive;

@end