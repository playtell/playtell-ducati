//
//  PTMemoryGameScoreView.m
//  playtell-ducati
//
//  Created by Dimitry Bentsionov on 10/10/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import "PTMemoryGameScoreView.h"

@implementation PTMemoryGameScoreView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    // Create front view (back of card + score)
    frontView = [[UIView alloc] initWithFrame:self.bounds];
    frontView.backgroundColor = [UIColor clearColor];
    UIImageView *cardView = [[UIImageView alloc] initWithFrame:self.bounds];
    cardView.image = [UIImage imageNamed:@"memory-match-marker.png"];
    lblScore = [[UILabel alloc] initWithFrame:self.bounds];
    lblScore.backgroundColor = [UIColor clearColor];
    lblScore.text = @"0";
    lblScore.textColor = [UIColor whiteColor];
    lblScore.font = [UIFont boldSystemFontOfSize:32.0f];
    lblScore.textAlignment = NSTextAlignmentCenter;
    [frontView addSubview:cardView];
    [frontView addSubview:lblScore];
    
    // Create back view (your turn star view)
    backView = [[UIView alloc] initWithFrame:self.bounds];
    backView.backgroundColor = [UIColor clearColor];
    UIImageView *yourTurnView = [[UIImageView alloc] initWithFrame:self.bounds];
    yourTurnView.image = [UIImage imageNamed:@"memory-turn-indicator.png"];
    [backView addSubview:yourTurnView];
    backView.hidden = YES;
    
    // Setup self and add children
    self.backgroundColor = [UIColor clearColor];
    [self addSubview:frontView];
    [self addSubview:backView];
    [self setNeedsDisplay];
}

- (void)setScore:(NSInteger)score {
    lblScore.text = [NSString stringWithFormat:@"%i", score];
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];

    // Set frame for all children
    frontView.frame = self.bounds;
    for (UIView *childFront in frontView.subviews) {
        childFront.frame = self.bounds;
    }
    backView.frame = self.bounds;
    for (UIView *childBack in backView.subviews) {
        childBack.frame = self.bounds;
    }
    [self setNeedsDisplay];
}

- (void)showYourTurn:(BOOL)isYourTurn delay:(BOOL)doDelay {
    if (isYourTurn == YES) {
        if (doDelay == YES) {
            [self performSelector:@selector(showBackView) withObject:nil afterDelay:2.0f];
        } else {
            [self showBackView];
        }
    } else {
        if (doDelay == YES) {
            [self performSelector:@selector(showFrontView) withObject:nil afterDelay:2.0f];
        } else {
            [self showFrontView];
        }
    }
}

- (void)showBackView {
    [UIView transitionWithView:self
                      duration:0.5f
                       options:UIViewAnimationOptionTransitionFlipFromLeft
                    animations:^{
                        frontView.hidden = YES;
                        backView.hidden = NO;
                    }
                    completion:^(BOOL finished){
                        frontView.hidden = YES;
                        backView.hidden = NO;
                    }];
}

- (void)showFrontView {
    [UIView transitionWithView:self
                      duration:0.5f
                       options:UIViewAnimationOptionTransitionFlipFromLeft
                    animations:^{
                        frontView.hidden = NO;
                        backView.hidden = YES;
                    }
                    completion:^(BOOL finished){
                        frontView.hidden = NO;
                        backView.hidden = YES;
                    }];
}

@end