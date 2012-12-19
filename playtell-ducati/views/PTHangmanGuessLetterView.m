//
//  PTHangmanGuessLetterView.m
//  playtell-ducati
//
//  Created by Dimitry Bentsionov on 12/18/12.
//  Copyright (c) 2012 PlayTell. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "PTHangmanGuessLetterView.h"

@implementation PTHangmanGuessLetterView

@synthesize letter = _letter;
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Setup the lbl
        lblLetter = [[UILabel alloc] init];
        lblLetter.font = [UIFont boldSystemFontOfSize:65.0f];
        lblLetter.text = @"";
        lblLetter.textColor = [UIColor whiteColor];
        lblLetter.textAlignment = NSTextAlignmentCenter;
        lblLetter.backgroundColor = [UIColor clearColor];
        lblLetter.userInteractionEnabled = NO;
        [self addSubview:lblLetter];
       
        // Background
        self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"hangman-letter"]];
        
        // Cover view
        coverView = [[UIView alloc] initWithFrame:self.bounds];
        coverView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"hangman-letterboard"]];
        [self addSubview:coverView];
        
        // Rasterize & crop
        self.layer.rasterizationScale = [UIScreen mainScreen].scale;
        self.layer.shouldRasterize = YES;
        self.clipsToBounds = YES;
    }
    return self;
}

- (void)setLetter:(NSString *)letter {
    // Save letter
    _letter = letter;
    
    // Set the lbl txt and positioning
    lblLetter.text = letter;
    [lblLetter sizeToFit];
    lblLetter.center = CGPointMake(self.bounds.size.width / 2.0f, self.bounds.size.height / 2.0f);

    // Animate the cover off
    [UIView animateWithDuration:1.0f
                     animations:^{
                         coverView.frame = CGRectOffset(coverView.frame, 0.0f, -coverView.bounds.size.height);
                     }];
    
    // TODO: Notify delegate?
}

@end