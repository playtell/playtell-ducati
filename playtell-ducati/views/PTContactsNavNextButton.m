//
//  PTContactsNavNextButton.m
//  playtell-ducati
//
//  Created by Dimitry Bentsionov on 8/3/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import "PTContactsNavNextButton.h"

@implementation PTContactsNavNextButton

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundImage:[UIImage imageNamed:@"buttonNextNormal"] forState:UIControlStateNormal];
        [self setBackgroundImage:[UIImage imageNamed:@"buttonNextHighlighted"] forState:UIControlStateHighlighted];
        [self setBackgroundImage:[UIImage imageNamed:@"buttonNextDisabled"] forState:UIControlStateDisabled];
        [self setTitle:@"Next" forState:UIControlStateNormal];
        self.titleLabel.font = [UIFont boldSystemFontOfSize:13.0f];
    }
    return self;
}

- (CGRect)titleRectForContentRect:(CGRect)contentRect {
    return CGRectOffset([super titleRectForContentRect:contentRect], -5.0f, 0.0f);
}

@end
