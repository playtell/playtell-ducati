//
//  PTMatchingPairingCardView.m
//  playtell-ducati
//
//  Created by Dimitry Bentsionov on 10/26/12.
//  Copyright (c) 2012 PlayTell. All rights reserved.
//

#import "PTMatchingPairingCardView.h"
#import "UIColor+ColorFromHex.h"
#import <QuartzCore/QuartzCore.h>

@implementation PTMatchingPairingCardView

@synthesize delegate;

- (id)initWithFrame:(CGRect)frame cardIndex:(NSInteger)_cardIndex delegate:(id<PTMachingGameDelegate>)_delegate {
    self = [super initWithFrame:frame];
    if (self) {
        // Save card index
        cardIndex = _cardIndex;

        // Save delegate
        delegate = _delegate;

        // Empty view
        imageLeftNormal = [UIImage imageNamed:@"matching-empty-match"];
        viewCardLeft = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, (frame.size.width / 2.0f), frame.size.height)];
        viewCardLeft.image = imageLeftNormal;
        [self addSubview:viewCardLeft];
        
        // Card view
        viewCardRight = [[UIImageView alloc] initWithFrame:CGRectMake((frame.size.width / 2.0f), 0.0f, (frame.size.width / 2.0f), frame.size.height)];
        [self addSubview:viewCardRight];
        
        // Center anchor layer
        self.layer.anchorPoint = CGPointMake(0.5f, 0.5f);
        
        // Load card image
        [self loadCardImage];
        isCardFlipped = NO;
        isCardMatched = NO;
        
        // Draw the lines
        self.clipsToBounds = NO;
        CGFloat halfWidth = frame.size.width / 2.0f;
        leftBorder = [[UIView alloc] initWithFrame:CGRectMake(-6.0f, -6.0f, halfWidth+6.0f, frame.size.height+12.0f)];
        leftBorder.backgroundColor = [UIColor whiteColor];
        leftBorder.hidden = YES;
        [self insertSubview:leftBorder belowSubview:viewCardLeft];
        rightBorder = [[UIView alloc] initWithFrame:CGRectMake(halfWidth, -6.0f, halfWidth+6.0f, frame.size.height+12.0f)];
        rightBorder.backgroundColor = [UIColor whiteColor];
        [self insertSubview:rightBorder belowSubview:viewCardRight];
        
        // Shadow
        leftBorder.layer.masksToBounds = NO;
        leftBorder.layer.shadowColor = [UIColor blackColor].CGColor;
        leftBorder.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
        leftBorder.layer.shadowOpacity = 0.8f;
        leftBorder.layer.shadowRadius = 6.0f;
        leftBorder.layer.shadowPath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, leftBorder.frame.size.height - 2, leftBorder.frame.size.width, 10)].CGPath;
        
        rightBorder.layer.masksToBounds = NO;
        rightBorder.layer.shadowColor = [UIColor blackColor].CGColor;
        rightBorder.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
        rightBorder.layer.shadowOpacity = 0.8f;
        rightBorder.layer.shadowRadius = 6.0f;
        rightBorder.layer.shadowPath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, rightBorder.frame.size.height - 2, rightBorder.frame.size.width, 10)].CGPath;
    }
    return self;
}

- (void)setFocusLevel:(CGFloat)focus {
    // Calculate needed values
    CGFloat z = -400.0f * (1.0f - focus);
    CGFloat opacity = 0.4f + (0.6f * focus);
    
    // Whole book
    if (isCardFlipped == YES) {
        self.layer.opacity = 0.3f;
    } else {
        self.layer.opacity = opacity;
    }
    
    // Cover
    CATransform3D coverTransform = CATransform3DIdentity;
    coverTransform.m34 = 1.0 / -1000;
    coverTransform = CATransform3DTranslate(coverTransform, 0.0f, 0.0f, z);
    self.layer.transform = coverTransform;
}

- (void)resetTransformation {
    CATransform3D coverTransform = CATransform3DIdentity;
    coverTransform.m34 = 1.0 / -1000;
    coverTransform = CATransform3DTranslate(coverTransform, 0.0f, 0.0f, 0.0f);
    self.layer.transform = coverTransform;
}

- (NSInteger)getCardIndex {
    return cardIndex;
}

#pragma mark - Card image methods

- (void)loadCardImage {
    imageRightNormal = [delegate matchingGameImageForCardIndex:cardIndex];
    imageRightMirror = nil;
    viewCardRight.image = imageRightNormal;
}

- (void)setEmptyCardViewWithImage:(UIImage*)image matchedByMe:(BOOL)_matchedByMe {
    imageLeftNormal = image;
    imageLeftMirror = nil;
    isCardMatched = YES;
    matchedByMe = _matchedByMe;
    
    // Generate mirror image if we're in that mode currently
    if (isCardFlipped == YES) {
        UIGraphicsBeginImageContext(imageLeftNormal.size);
        CGContextRef bitmap = UIGraphicsGetCurrentContext();
        CGAffineTransform transform = CGAffineTransformMake(-1.0, 0.0, 0.0, 1.0, imageLeftNormal.size.width, 0.0);
        CGContextConcatCTM(bitmap, transform);
        [imageLeftNormal drawInRect:CGRectMake(0, 0, imageLeftNormal.size.width, imageLeftNormal.size.height)];
        imageLeftMirror = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();

        viewCardRight.image = imageLeftMirror;
        rightBorder.hidden = NO;
    } else {
        viewCardLeft.image = imageLeftNormal;
        leftBorder.hidden = NO;
    }
}

- (void)resetEmptyCardView {
    imageLeftNormal = [UIImage imageNamed:@"matching-empty-match"];
    imageLeftMirror = nil;
    isCardMatched = NO;

    // Generate mirror image if we're in that mode currently
    if (isCardFlipped == YES) {
        UIGraphicsBeginImageContext(imageLeftNormal.size);
        CGContextRef bitmap = UIGraphicsGetCurrentContext();
        CGAffineTransform transform = CGAffineTransformMake(-1.0, 0.0, 0.0, 1.0, imageLeftNormal.size.width, 0.0);
        CGContextConcatCTM(bitmap, transform);
        [imageLeftNormal drawInRect:CGRectMake(0, 0, imageLeftNormal.size.width, imageLeftNormal.size.height)];
        imageLeftMirror = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        viewCardRight.image = imageLeftMirror;
        rightBorder.hidden = YES;
    } else {
        viewCardLeft.image = imageLeftNormal;
        leftBorder.hidden = YES;
    }
}

- (void)flipCardsToMirror {
    isCardFlipped = YES;
    
    // Right mirror
    if (imageRightMirror == nil) {
        UIGraphicsBeginImageContext(imageRightNormal.size);
        CGContextRef bitmap = UIGraphicsGetCurrentContext();
        CGAffineTransform transform = CGAffineTransformMake(-1.0, 0.0, 0.0, 1.0, imageRightNormal.size.width, 0.0);
        CGContextConcatCTM(bitmap, transform);
        [imageRightNormal drawInRect:CGRectMake(0, 0, imageRightNormal.size.width, imageRightNormal.size.height)];
        imageRightMirror = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    // Left mirror
    if (imageLeftMirror == nil) {
        UIGraphicsBeginImageContext(imageLeftNormal.size);
        CGContextRef bitmap = UIGraphicsGetCurrentContext();
        CGAffineTransform transform = CGAffineTransformMake(-1.0, 0.0, 0.0, 1.0, imageLeftNormal.size.width, 0.0);
        CGContextConcatCTM(bitmap, transform);
        [imageLeftNormal drawInRect:CGRectMake(0, 0, imageLeftNormal.size.width, imageLeftNormal.size.height)];
        imageLeftMirror = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    // Assign mirror images
    viewCardLeft.image = imageRightMirror;
    viewCardRight.image = imageLeftMirror;
    
    // Show appropriate border
    leftBorder.hidden = NO;
    rightBorder.hidden = isCardMatched ? NO : YES;
}

- (void)flipCardsToNormal {
    isCardFlipped = NO;

    // Assign normal images
    viewCardLeft.image = imageLeftNormal;
    viewCardRight.image = imageRightNormal;

    // Show appropriate border
    leftBorder.hidden = isCardMatched ? NO : YES;
    rightBorder.hidden = NO;
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
    // Change the color of the border
    NSString *bgColor = matchedByMe ? @"#17a84b" : @"#f48511";
    [UIView animateWithDuration:0.3f
                     animations:^{
                         leftBorder.backgroundColor = [UIColor colorFromHex:bgColor];
                         rightBorder.backgroundColor = [UIColor colorFromHex:bgColor];
                     }];

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
                             [delegate matchingGamePairingCardDidFinishUpDownAnimation];
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
                             [delegate matchingGamePairingCardDidFinishLeftRightAnimation];
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

@end