//
//  PTMathAvailableCardView.m
//  playtell-ducati
//
//  Created by Dimitry Bentsionov on 11/12/12.
//  Copyright (c) 2012 PlayTell. All rights reserved.
//

#import "PTMathAvailableCardView.h"

@implementation PTMathAvailableCardView

@synthesize delegate;

- (id)initWithFrame:(CGRect)frame cardIndex:(NSInteger)_cardIndex delegate:(id<PTMathGameDelegate>)_delegate {
    self = [super initWithFrame:frame];
    if (self) {
        cardIndex = _cardIndex;
        delegate = _delegate;
        childView = [[UIImageView alloc] initWithFrame:self.bounds];
        [self addSubview:childView];
        
        // Load the card image
        //[self loadCardImage];
    }
    return self;
}

- (NSInteger)getCardIndex {
    return cardIndex;
}

#pragma mark - Touches detection

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [delegate mathGameAvailableCardTouchesBegan:self touch:[[[event allTouches] allObjects] objectAtIndex:0]];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [delegate mathGameAvailableCardTouchesCancelled:self touch:[[[event allTouches] allObjects] objectAtIndex:0]];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [delegate mathGameAvailableCardTouchesEnded:self touch:[[[event allTouches] allObjects] objectAtIndex:0]];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [delegate mathGameAvailableCardTouchesMoved:self touch:[[[event allTouches] allObjects] objectAtIndex:0]];
}

#pragma mark - Card image loading

- (void)loadCardImage {
    childView.image = [delegate mathGameImageForCardIndex:cardIndex];
}

- (UIImage*)getCardImage {
    return childView.image;
}

- (void)setCardImage:(UIImage *)image {
    cardImage = image;
    childView.image = cardImage;
}

@end