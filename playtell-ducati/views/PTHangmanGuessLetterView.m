//
//  PTHangmanGuessLetterView.m
//  playtell-ducati
//
//  Created by Dimitry Bentsionov on 12/18/12.
//  Copyright (c) 2012 PlayTell. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "PTHangmanGuessLetterView.h"
#import "UIColor+HexColor.h"

@implementation PTHangmanGuessLetterView

@synthesize letter = _letter;
@synthesize delegate;
@synthesize type = _type;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Type
        _type = PTHangmanLetterTypeGuessedRight;
        
        // Setup the lbl
        lblLetter = [[UILabel alloc] init];
        lblLetter.font = [UIFont boldSystemFontOfSize:65.0f];
        lblLetter.text = @"";
        lblLetter.textAlignment = NSTextAlignmentCenter;
        lblLetter.backgroundColor = [UIColor clearColor];
        lblLetter.userInteractionEnabled = NO;
        lblLetter.textColor = [UIColor colorFromHex:@"#7da839"];
        lblLetter.layer.shadowColor = [UIColor colorFromHex:@"#00000"].CGColor;
        lblLetter.layer.shadowOffset = CGSizeMake(1.0f, 1.0f);
        lblLetter.layer.shadowRadius = 1.0f;
        lblLetter.layer.shadowOpacity = 0.2f;
       
        // Letter container
        letterContainer = [[UIView alloc] initWithFrame:self.bounds];
        letterContainer.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"hangman-letterboard"]];
        letterContainer.frame = CGRectOffset(letterContainer.frame, 0.0f, -letterContainer.bounds.size.height);
        [letterContainer addSubview:lblLetter];
        [self addSubview:letterContainer];
        
        // Cover view
        coverView = [[UIView alloc] initWithFrame:self.bounds];
        coverView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"hangman-letter"]];
        [self insertSubview:coverView belowSubview:letterContainer];
        
        // Rasterize & crop
        self.layer.rasterizationScale = [UIScreen mainScreen].scale;
        self.layer.shouldRasterize = YES;
        self.clipsToBounds = YES;
    }
    return self;
}

- (void)setLetter:(NSString *)letter {
    // Save letter
    _letter = [letter uppercaseString];
    
    // Set the lbl txt and positioning
    lblLetter.text = letter;
    [lblLetter sizeToFit];
    lblLetter.center = CGPointMake(self.bounds.size.width / 2.0f, self.bounds.size.height / 2.0f);

    // Animate the letter into view
    [UIView animateWithDuration:1.0f
                     animations:^{
                         letterContainer.frame = CGRectOffset(letterContainer.frame, 0.0f, letterContainer.bounds.size.height);
                     }];
}

- (void)setType:(PTHangmanLetterType)type {
    _type = type;
    
    switch (type) {
        case PTHangmanLetterTypeGuessedRight:
            lblLetter.textColor = [UIColor colorFromHex:@"#7da839"];
            break;
        case PTHangmanLetterTypeGuessedWrong:
            lblLetter.textColor = [UIColor colorFromHex:@"#d1775f"];
            break;
        case PTHangmanLetterTypeAvailable:
            break;
    }
}

@end