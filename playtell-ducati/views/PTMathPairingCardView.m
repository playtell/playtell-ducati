//
//  PTMathPairingCardView.m
//  playtell-ducati
//
//  Created by Dimitry Bentsionov on 11/12/12.
//  Copyright (c) 2012 PlayTell. All rights reserved.
//

#import "PTMathPairingCardView.h"
#import "UIColor+ColorFromHex.h"
#import <QuartzCore/QuartzCore.h>

@implementation PTMathPairingCardView

@synthesize delegate;

- (id)initWithFrame:(CGRect)frame cardIndex:(NSInteger)_cardIndex delegate:(id<PTMathGameDelegate>)_delegate {
    self = [super initWithFrame:frame];
    if (self) {
        // Save card index
        cardIndex = _cardIndex;
        
        // Save delegate
        delegate = _delegate;
        
        // Empty view
        viewCardLeft = [[UIImageView alloc] initWithFrame:CGRectMake(10.0f, 10.0f, 215.0f, 215.0f)];
        [self addSubview:viewCardLeft];
        
        // Placeholder view
        viewCardPlaceholder = [[UIImageView alloc] initWithFrame:CGRectMake(235.0f, 20.0f, 308.0f, 203.0f)];
        viewCardPlaceholder.image = [UIImage imageNamed:@"math-placeholder-outline"];
        [self addSubview:viewCardPlaceholder];
        
        // Card view
        viewCardRight = [[UIImageView alloc] initWithFrame:CGRectMake(245.0f, 35.0f, 288.0f, 183.0f)];
        [self insertSubview:viewCardRight aboveSubview:viewCardPlaceholder];
        
        // Load card image
        [self loadCardImage];
        isCardMatched = NO;
    }
    return self;
}

- (NSInteger)getCardIndex {
    return cardIndex;
}

#pragma mark - Card image methods

- (void)loadCardImage {
    viewCardLeft.image = [delegate mathGameImageForCardIndex:cardIndex];
}

- (void)setEmptyCardViewWithImage:(UIImage*)image matchedByMe:(BOOL)_matchedByMe {
    isCardMatched = YES;
    matchedByMe = _matchedByMe;
    viewCardLeft.image = image;
}

- (void)resetEmptyCardView {
    isCardMatched = NO;
    viewCardLeft.image = nil;
}

#pragma mark - Animations

- (void)jumpUpDownDelayed:(BOOL)doDelay {
    if (doDelay == YES) {
        [self performSelector:@selector(jumpUpDown) withObject:nil afterDelay:1.0f];
    } else {
        [self jumpUpDown];
    }
}

- (void)jumpUpDown {
    // Animate
    animationCount = 0;
    [self animateUpAllTheWay:NO];
}

- (void)animateUpAllTheWay:(BOOL)allTheWay {
    CGFloat offset = allTheWay ? -10.0f : -5.0f;
    [UIView animateWithDuration:0.1f
                     animations:^{
                         self.frame = CGRectOffset(self.frame, 0.0f, offset);
                     }
                     completion:^(BOOL finished) {
                         if (animationCount < 3) {
                             [self animateDownAllTheWay:YES];
                         } else {
                             // Animation is finished
                             [delegate mathGamePairingCardDidFinishUpDownAnimation];
                         }
                     }];
}

- (void)animateDownAllTheWay:(BOOL)allTheWay {
    CGFloat offset = allTheWay ? 10.0f : 5.0f;
    [UIView animateWithDuration:0.1f
                     animations:^{
                         self.frame = CGRectOffset(self.frame, 0.0f, offset);
                     }
                     completion:^(BOOL finished) {
                         animationCount++;
                         if (animationCount == 3) {
                             // Return to starting position
                             [self animateUpAllTheWay:NO];
                         } else {
                             [self animateUpAllTheWay:YES];
                         }
                     }];
}

- (void)jumpLeftRightDelayed:(BOOL)doDelay {
    if (doDelay == YES) {
        [self performSelector:@selector(jumpLeftRight) withObject:nil afterDelay:1.0f];
    } else {
        [self jumpLeftRight];
    }
}

- (void)jumpLeftRight {
    // Animate
    animationCount = 0;
    [self animateLeftAllTheWay:NO];
}

- (void)animateLeftAllTheWay:(BOOL)allTheWay {
    CGFloat offset = allTheWay ? -10.0f : -5.0f;
    [UIView animateWithDuration:0.1f
                     animations:^{
                         self.frame = CGRectOffset(self.frame, offset, 0.0f);
                     }
                     completion:^(BOOL finished) {
                         if (animationCount < 3) {
                             [self animateRightAllTheWay:YES];
                         } else {
                             // Animation is finished
                             [delegate mathGamePairingCardDidFinishLeftRightAnimation];
                         }
                     }];
}

- (void)animateRightAllTheWay:(BOOL)allTheWay {
    CGFloat offset = allTheWay ? 10.0f : 5.0f;
    [UIView animateWithDuration:0.1f
                     animations:^{
                         self.frame = CGRectOffset(self.frame, offset, 0.0f);
                     }
                     completion:^(BOOL finished) {
                         animationCount++;
                         if (animationCount == 3) {
                             // Return to starting position
                             [self animateLeftAllTheWay:NO];
                         } else {
                             [self animateLeftAllTheWay:YES];
                         }
                     }];
}

#pragma mark - Landing zone

- (void)setLandingZoneAsActive {
    viewCardPlaceholder.image = [UIImage imageNamed:@"math-placeholder-highlight"];
}

- (void)setLandingZoneAsInactive {
    viewCardPlaceholder.image = [UIImage imageNamed:@"math-placeholder-outline"];
}

@end