//
//  PTMatchingAvailableCardView.m
//  playtell-ducati
//
//  Created by Dimitry Bentsionov on 10/25/12.
//  Copyright (c) 2012 PlayTell. All rights reserved.
//

#import "PTMatchingAvailableCardView.h"
#import "PTMatchingAvailableCardsView.h"
#import <QuartzCore/QuartzCore.h>

@implementation PTMatchingAvailableCardView

@synthesize delegate;

- (id)initWithFrame:(CGRect)frame cardIndex:(NSInteger)_cardIndex delegate:(id<PTMachingGameDelegate>)_delegate {
    self = [super initWithFrame:frame];
    if (self) {
        cardIndex = _cardIndex;
        delegate = _delegate;
        childView = [[UIImageView alloc] initWithFrame:CGRectMake(10.0f, 0.0f, frame.size.width - 20.0f, frame.size.height)];
        [self addSubview:childView];
        
        // Load the card image
        [self loadCardImage];
        
        // Draw the border
        borderView = [[UIView alloc] initWithFrame:CGRectMake(4.0f, -6.0f, frame.size.width - 14.0f, frame.size.height+12.0f)];
        borderView.backgroundColor = [UIColor whiteColor];
        [self insertSubview:borderView belowSubview:childView];
        
        // Shadow
        borderView.layer.masksToBounds = NO;
        borderView.layer.shadowColor = [UIColor blackColor].CGColor;
        borderView.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
        borderView.layer.shadowOpacity = 0.8f;
        borderView.layer.shadowRadius = 6.0f;
        borderView.layer.shouldRasterize = YES;
        borderView.layer.shadowPath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, borderView.frame.size.height - 2, borderView.frame.size.width, 10)].CGPath;
    }
    return self;
}

- (void)setFocusLevel:(CGFloat)focus {
//    NSLog(@"%i - %.2f", cardIndex, focus);
}

- (NSInteger)getCardIndex {
    return cardIndex;
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

#pragma mark - Card image loading

- (void)loadCardImage {
    childView.image = [delegate matchingGameImageForCardIndex:cardIndex];
}

- (UIImage*)getCardImage {
    return childView.image;
}

@end