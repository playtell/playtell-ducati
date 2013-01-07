//
//  PTHangmanLetterView.m
//  playtell-ducati
//
//  Created by Dimitry Bentsionov on 12/17/12.
//  Copyright (c) 2012 PlayTell. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "PTHangmanLetterView.h"
#import "UIColor+HexColor.h"

@implementation PTHangmanLetterView

@synthesize letter = _letter;
@synthesize delegate;
@synthesize type = _type;

- (id)initWithFrame:(CGRect)frame letter:(NSString*)letter {
    self = [super initWithFrame:frame];
    if (self) {
        self.letter = letter;
        
        // Type
        _type = PTHangmanLetterTypeAvailable;

        // Setup the lbl
        lblLetter = [[UILabel alloc] init];
        lblLetter.font = [UIFont boldSystemFontOfSize:65.0f];
        lblLetter.text = letter;
        lblLetter.textAlignment = NSTextAlignmentCenter;
        [lblLetter sizeToFit];
        lblLetter.center = CGPointMake(self.bounds.size.width / 2.0f, self.bounds.size.height / 2.0f);
        lblLetter.backgroundColor = [UIColor clearColor];
        lblLetter.userInteractionEnabled = NO;
        lblLetter.textColor = [UIColor colorFromHex:@"#d8b683"];
        lblLetter.layer.shadowColor = [UIColor colorFromHex:@"#00000"].CGColor;
        lblLetter.layer.shadowOffset = CGSizeMake(1.0f, 1.0f);
        lblLetter.layer.shadowRadius = 1.0f;
        lblLetter.layer.shadowOpacity = 0.2f;
        [self addSubview:lblLetter];
        
        // Tap recognizer
        UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(letterDidTap:)];
        [self addGestureRecognizer:recognizer];
        
        // Background
        self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"hangman-letterboard"]];
        
        // Rasterize!
        self.layer.rasterizationScale = [UIScreen mainScreen].scale;
        self.layer.shouldRasterize = YES;
    }
    return self;
}

- (void)letterDidTap:(UIGestureRecognizer*)recognizer {
    // Only allow taps on available cards (those that haven't been guessed yet)
    if (self.type != PTHangmanLetterTypeAvailable) {
        return;
    }

    // Temprarily dip opacity to imitate touch
    self.alpha = 0.5f;
    [self performSelector:@selector(returnToNormalOpacity) withObject:nil afterDelay:0.1f];
}

- (void)returnToNormalOpacity {
    // Restore opacity
    self.alpha = 1.0f;
    
    // Notify delegate
    if ([delegate respondsToSelector:@selector(letterViewDidPress:letter:)]) {
        [delegate letterViewDidPress:self letter:self.letter];
    }
}

- (void)setType:(PTHangmanLetterType)type {
    _type = type;

    switch (type) {
        case PTHangmanLetterTypeAvailable:
            lblLetter.textColor = [UIColor colorFromHex:@"#d8b683"];
            self.layer.borderWidth = 0.0f;
            self.alpha = 1.0f;
            break;
        case PTHangmanLetterTypeGuessedRight:
            lblLetter.textColor = [UIColor colorFromHex:@"#7da839"];
            self.layer.borderColor = [UIColor colorFromHex:@"#7da839"].CGColor;
            self.layer.borderWidth = 4.0f;
            self.alpha = 0.5f;
            break;
        case PTHangmanLetterTypeGuessedWrong:
            lblLetter.textColor = [UIColor colorFromHex:@"#d1775f"];
            self.layer.borderColor = [UIColor colorFromHex:@"#d1775f"].CGColor;
            self.layer.borderWidth = 4.0f;
            self.alpha = 0.5f;
            break;
    }
}

@end