//
//  PTMemoryGameCard.m
//  playtell-ducati
//
//  PTMemoryCard class encompasses a single card object on the board. "boardIndex" is
//  what's used by the rails backend to determine whether or not two selected cards have
//  been matched. The "front" of the card, as referred to in code, is the side of the card
//  that contains the artwork, the "back" is not unique.
//
//  Created by Giancarlo Daniele on 8/24/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import "PTMemoryGameCard.h"

@implementation PTMemoryGameCard

@synthesize containerView;
@synthesize card;
@synthesize coordinates;
@synthesize size;
@synthesize delegate;

- (id)initWithFrontFilename:(NSString *)front_filename
               backFilename:(NSString *)back_filename
               indexOnBoard:(NSInteger)board_index
              numberOfCards:(NSInteger)num_cards {
    
    // Container view
    containerView = [UIView new];
    containerView.backgroundColor = [UIColor clearColor];
    
    // Placeholder view
    placeholderView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"card-placeholder.png"]];
    placeholderView.hidden = YES;

    // Card UIButton
    card = [UIButton buttonWithType:UIButtonTypeCustom];
    back = [UIImage imageNamed:back_filename];
    front = [UIImage imageNamed:front_filename];
    [card setBackgroundImage:back forState:UIControlStateNormal];
    [card addTarget:self action:@selector(cardTouched:) forControlEvents:UIControlEventTouchUpInside];
    [card setTag:board_index];
    card.adjustsImageWhenDisabled = NO;
    
    [containerView addSubview:card];
    [containerView insertSubview:placeholderView belowSubview:card];

    // Setup the card object
    boardIndex = board_index;
    isBackShown = YES;
    isCardEnabled = YES;

    // Set these based on the num cards
    if (num_cards == 12) {
        size = CGSizeMake(128.0f, 179.0f);
    } else {
        size = CGSizeMake(164.0f, 225.0f);
    }

    // Setup card coordinates
    coordinates = [[PTMemoryCardCoordinate alloc] initWithNumCards:num_cards
                                                             index:boardIndex];
    return self;
}

- (void)setFrame:(CGRect)frame {
    containerView.frame = frame;
    card.frame = self.containerView.bounds;
    placeholderView.frame = self.containerView.bounds;
}

- (void)flipCard {
    UIImage *otherSideImage = isBackShown ? front : back;
    
    [UIView transitionWithView:card
                      duration:0.5f
                       options:UIViewAnimationOptionTransitionFlipFromLeft
                    animations:^{
                        [card setBackgroundImage:otherSideImage forState:UIControlStateNormal];
                    }
                    completion:^(BOOL finished){
                        [card setBackgroundImage:otherSideImage forState:UIControlStateNormal];
                    }];

    isBackShown = !isBackShown;
}

- (void)flipCardDelayed:(BOOL)doDelay {
    if (doDelay == YES) {
        [self performSelector:@selector(flipCard) withObject:nil afterDelay:1.0f];
    } else {
        [self flipCard];
    }
}

- (IBAction)cardTouched:(id)sender {
    // Are we allowed to flip the card?
    if ([self.delegate memoryGameCardShouldFlip:boardIndex] == YES) {
        // Flip the card
        [self flipCard];
        
        // Notify delegate
        [self.delegate memoryGameCardDidFlip:boardIndex];
    }
}

- (void)disableCard {
    self.card.enabled = NO;
    self.card.userInteractionEnabled = NO;
}

- (void)enableCard {
    self.card.enabled = YES;
    self.card.userInteractionEnabled = YES;
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
    // Disabled interactions while animation happening
    [self disableCard];
    
    // Animate
    animationCount = 0;
    [self animateUpAllTheWay:NO];
}

- (void)animateUpAllTheWay:(BOOL)allTheWay {
    CGFloat offset = allTheWay ? -10.0f : -5.0f;
    [UIView animateWithDuration:0.1f
                     animations:^{
                         card.frame = CGRectOffset(card.frame, 0.0f, offset);
                     }
                     completion:^(BOOL finished) {
                         if (animationCount < 3) {
                             [self animateDownAllTheWay:YES];
                         } else {
                             // Animation is finished; Show placeholder instead of card
                             placeholderView.hidden = NO;
                             [UIView animateWithDuration:0.5f
                                              animations:^{
                                                  card.alpha = 0.0f;
                                              }];
                         }
                     }];
}

- (void)animateDownAllTheWay:(BOOL)allTheWay {
    CGFloat offset = allTheWay ? 10.0f : 5.0f;
    [UIView animateWithDuration:0.1f
                     animations:^{
                         card.frame = CGRectOffset(card.frame, 0.0f, offset);
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
    // Disabled interactions while animation happening
    [self disableCard];
    
    // Animate
    animationCount = 0;
    [self animateLeftAllTheWay:NO];
}

- (void)animateLeftAllTheWay:(BOOL)allTheWay {
    CGFloat offset = allTheWay ? -10.0f : -5.0f;
    [UIView animateWithDuration:0.1f
                     animations:^{
                         card.frame = CGRectOffset(card.frame, offset, 0.0f);
                     }
                     completion:^(BOOL finished) {
                         if (animationCount < 3) {
                             [self animateRightAllTheWay:YES];
                         } else {
                             // Animation is finished; Flip card back.
                             [self flipCard];
                             [self enableCard];
                         }
                     }];
}

- (void)animateRightAllTheWay:(BOOL)allTheWay {
    CGFloat offset = allTheWay ? 10.0f : 5.0f;
    [UIView animateWithDuration:0.1f
                     animations:^{
                         card.frame = CGRectOffset(card.frame, offset, 0.0f);
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



@end