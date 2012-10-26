//
//  PTMatchingPairingCardView.m
//  playtell-ducati
//
//  Created by Dimitry Bentsionov on 10/26/12.
//  Copyright (c) 2012 PlayTell. All rights reserved.
//

#import "PTMatchingPairingCardView.h"
#import <QuartzCore/QuartzCore.h>

@implementation PTMatchingPairingCardView

- (id)initWithFrame:(CGRect)frame cardIndex:(NSInteger)_cardIndex {
    self = [super initWithFrame:frame];
    if (self) {
        // Save card index
        cardIndex = _cardIndex;

        // Empty view
        UIImageView *viewEmptyCard = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, (frame.size.width / 2.0f), frame.size.height)];
        viewEmptyCard.image = [UIImage imageNamed:@"matching-empty-match"];
        [self addSubview:viewEmptyCard];
        
        // Car view
        UIImageView *viewCard = [[UIImageView alloc] initWithFrame:CGRectMake((frame.size.width / 2.0f), 0.0f, (frame.size.width / 2.0f), frame.size.height)];
        viewCard.backgroundColor = [UIColor redColor];
        //viewCard.image = [UIImage imageNamed:@"matching-empty-match"];
        [self addSubview:viewCard];
    }
    return self;
}

- (void)setFocusLevel:(CGFloat)focus {
    // Calculate needed values
    CGFloat z = -400.0f * (1.0f - focus);
    CGFloat opacity = 0.4f + (0.6f * focus);
    
    // Whole book
    self.layer.opacity = opacity;
    
    // Cover
    CATransform3D coverRotation = CATransform3DIdentity;
    coverRotation.m34 = 1.0 / -1000;
    coverRotation = CATransform3DTranslate(coverRotation, 0.0f, 0.0f, z);
    //coverRotation = CATransform3DRotate(coverRotation, degreesToRadians(0.0f), 0.0f, 1.0f, 0.0f);
    self.layer.transform = coverRotation;
}

@end