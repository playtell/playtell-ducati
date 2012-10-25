//
//  PTMatchingAvailableCardView.m
//  playtell-ducati
//
//  Created by Dimitry Bentsionov on 10/25/12.
//  Copyright (c) 2012 PlayTell. All rights reserved.
//

#import "PTMatchingAvailableCardView.h"
#import "PTMatchingAvailableCardsView.h"

@implementation PTMatchingAvailableCardView

@synthesize delegate;

- (id)initWithFrame:(CGRect)frame cardIndex:(NSInteger)_cardIndex {
    self = [super initWithFrame:frame];
    if (self) {
        cardIndex = _cardIndex;
        childView = [[UIView alloc] initWithFrame:CGRectMake(10.0f, 0.0f, frame.size.width - 20.0f, frame.size.height)];
        childView.backgroundColor = [UIColor yellowColor];
        [self addSubview:childView];
    }
    return self;
}

- (void)setFocusLevel:(CGFloat)focus {
    NSLog(@"%i - %.2f", cardIndex, focus);
}

#pragma mark - Touches detection

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [delegate matchingGameAvailableCardTouchesBegan:self touch:[[[event allTouches] allObjects] objectAtIndex:0]];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [delegate matchingGameAvailableCardTouchesCancelled:self touch:[[[event allTouches] allObjects] objectAtIndex:0]];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [delegate matchingGameAvailableCardTouchesEnded:self touch:[[[event allTouches] allObjects] objectAtIndex:0]];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [delegate matchingGameAvailableCardTouchesMoved:self touch:[[[event allTouches] allObjects] objectAtIndex:0]];
}

@end
