//
//  PTHangmanLetterView.m
//  playtell-ducati
//
//  Created by Dimitry Bentsionov on 12/17/12.
//  Copyright (c) 2012 PlayTell. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "PTHangmanLetterView.h"

@implementation PTHangmanLetterView

@synthesize letter = _letter;
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame letter:(NSString*)letter {
    self = [super initWithFrame:frame];
    if (self) {
        self.letter = letter;

        // Setup the lbl
        lblLetter = [[UILabel alloc] init];
        lblLetter.font = [UIFont boldSystemFontOfSize:65.0f];
        lblLetter.text = letter;
        lblLetter.textColor = [UIColor whiteColor];
        lblLetter.textAlignment = NSTextAlignmentCenter;
        [lblLetter sizeToFit];
        lblLetter.center = CGPointMake(self.bounds.size.width / 2.0f, self.bounds.size.height / 2.0f);
        lblLetter.backgroundColor = [UIColor clearColor];
        lblLetter.userInteractionEnabled = NO;
        [self addSubview:lblLetter];
        
        // Tap recognizer
        UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(letterDidTap:)];
        [self addGestureRecognizer:recognizer];
        
        // Background
        self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"hangman-letter"]];
        
        // Rasterize!
        self.layer.rasterizationScale = [UIScreen mainScreen].scale;
        self.layer.shouldRasterize = YES;
    }
    return self;
}

- (void)letterDidTap:(UIGestureRecognizer*)recognizer {
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

@end