//
//  PTMatchingPairingCardView.h
//  playtell-ducati
//
//  Created by Dimitry Bentsionov on 10/26/12.
//  Copyright (c) 2012 PlayTell. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PTMatchingAvailableCardView.h"

@interface PTMatchingPairingCardView : UIView {
    NSInteger cardIndex;
    id<PTMachingGameDelegate> delegate;
    UIImageView *viewCardLeft;
    UIImageView *viewCardRight;
    NSInteger animationCount;
    UIImage *imageLeftNormal;
    UIImage *imageLeftMirror;
    UIImage *imageRightNormal;
    UIImage *imageRightMirror;
    BOOL isCardFlipped;
    BOOL isCardMatched;
    BOOL matchedByMe;
    
    // Lines views
    UIView *leftBorder;
    UIView *rightBorder;
}

@property (nonatomic, retain) id<PTMachingGameDelegate> delegate;

- (id)initWithFrame:(CGRect)frame cardIndex:(NSInteger)_cardIndex delegate:(id<PTMachingGameDelegate>)_delegate;
- (void)setFocusLevel:(CGFloat)focus;
- (void)resetTransformation;
- (NSInteger)getCardIndex;
- (void)setEmptyCardViewWithImage:(UIImage*)image matchedByMe:(BOOL)_matchedByMe;
- (void)resetEmptyCardView;
- (void)jumpUpDownDelayed:(BOOL)doDelay;
- (void)jumpUpDown;
- (void)jumpLeftRightDelayed:(BOOL)doDelay;
- (void)jumpLeftRight;
- (void)flipCardsToMirror;
- (void)flipCardsToNormal;

@end