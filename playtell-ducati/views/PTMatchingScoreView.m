//
//  PTMatchingScoreView.m
//  playtell-ducati
//
//  Created by Dimitry Bentsionov on 10/31/12.
//  Copyright (c) 2012 PlayTell. All rights reserved.
//

#import "PTMatchingScoreView.h"
#import "UIColor+ColorFromHex.h"

@implementation PTMatchingScoreView

- (id)initWithFrame:(CGRect)frame myScore:(BOOL)myScore {
    self = [super initWithFrame:frame];
    if (self) {
        isMyScore = myScore;
        [self setup];
    }
    return self;
}

- (void)setup {
    // Create background image
    bgView = [[UIImageView alloc] initWithFrame:self.bounds];
    bgView.image = isMyScore ? [UIImage imageNamed:@"matching-score-green"] : [UIImage imageNamed:@"matching-score-orange"];
    [self addSubview:bgView];
    
    // Create score label
    lblScore = [[UILabel alloc] initWithFrame:self.bounds];
    lblScore.backgroundColor = [UIColor clearColor];
    lblScore.text = @"0";
    lblScore.font = [UIFont boldSystemFontOfSize:32.0f];
    lblScore.textAlignment = NSTextAlignmentCenter;
    lblScore.frame = self.bounds;
    lblScore.shadowColor = [UIColor colorFromHex:@"#ffffff" alpha:0.5f];
    lblScore.shadowOffset = CGSizeMake(0, 1);
    lblScore.contentMode = UIViewContentModeCenter;
    if (isMyScore) {
        lblScore.textColor = [UIColor colorFromHex:@"#00683d"];
    } else {
        lblScore.textColor = [UIColor colorFromHex:@"#7f4512"];
    }
    [self addSubview:lblScore];
    
    // Setup self and add children
    self.backgroundColor = [UIColor clearColor];
    
    // Default score
    score = 0;
}

- (void)setScore:(NSInteger)_score {
    if (score == _score) {
        return;
    }
    lblScore.text = [NSString stringWithFormat:@"%i", _score];
    [self grownShrink];
    score = _score;
}

- (void)grownShrink {
    [UIView animateWithDuration:0.5f
                     animations:^{
                         self.frame = CGRectMake(self.frame.origin.x-8.0f, self.frame.origin.y-12.0f, 75.0f, 100.0f);
                         bgView.frame = CGRectMake(0.0f, 0.0f, 75.0f, 100.0f);
                         lblScore.frame = CGRectMake(0.0f, 0.0f, 75.0f, 100.0f);
                     }
                     completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.5f
                                          animations:^{
                                              self.frame = CGRectMake(self.frame.origin.x+8.0f, self.frame.origin.y+12.0f, 56.0f, 75.0f);
                                              bgView.frame = CGRectMake(0.0f, 0.0f, 56.0f, 75.0f);
                                              lblScore.frame = CGRectMake(0.0f, 0.0f, 56.0f, 75.0f);
                                          }];
                     }];
}

@end