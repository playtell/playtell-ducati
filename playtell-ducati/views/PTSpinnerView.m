//
//  PTSpinnerView.m
//  playtell-ducati
//
//  Created by Adam Horne on 12/3/12.
//  Copyright (c) 2012 PlayTell. All rights reserved.
//

#define CIRCLE_SIZE     600.0

#import "PTSpinnerView.h"

@interface PTSpinnerView ()

@property (nonatomic, strong) UIImageView *animationView;

@end

@implementation PTSpinnerView

@synthesize animationView;

- (id)init {
    self = [super initWithFrame:CGRectMake(0.0f, 0.0f, CIRCLE_SIZE, CIRCLE_SIZE)];
    if (self) {
        [self setImage:[UIImage imageNamed:@"crank-circle.png"]];
        self.autoresizesSubviews = YES;
        
        // Create animation
        animationView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CIRCLE_SIZE, CIRCLE_SIZE)];
        animationView.frame = CGRectOffset(animationView.frame, 0.0f, -5.0f);
        [animationView setImage:[UIImage imageNamed:@"crank1.png"]];
        animationView.animationImages = [NSArray arrayWithObjects:
                                         [UIImage imageNamed:@"crank1.png"],
                                         [UIImage imageNamed:@"crank2.png"],
                                         [UIImage imageNamed:@"crank3.png"],
                                         [UIImage imageNamed:@"crank4.png"],
                                         [UIImage imageNamed:@"crank5.png"],
                                         [UIImage imageNamed:@"crank6.png"],
                                         [UIImage imageNamed:@"crank7.png"],
                                         [UIImage imageNamed:@"crank8.png"],
                                         [UIImage imageNamed:@"crank9.png"],
                                         [UIImage imageNamed:@"crank10.png"],
                                         nil];
        animationView.animationDuration = 1.0;
        animationView.animationRepeatCount = 0;
        animationView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self addSubview:animationView];
    }
    return self;
}

- (void)startSpinning {
    [animationView startAnimating];
}

- (void)stopSpinning {
    [animationView stopAnimating];
}

@end
