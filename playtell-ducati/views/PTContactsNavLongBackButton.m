//
//  PTContactsNavLongBackButton.m
//  playtell-ducati
//
//  Created by Dimitry Bentsionov on 9/27/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import "PTContactsNavLongBackButton.h"

@implementation PTContactsNavLongBackButton

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundImage:[UIImage imageNamed:@"buttonBackLongNormal"] forState:UIControlStateNormal];
        [self setBackgroundImage:[UIImage imageNamed:@"buttonBackLongHighlighted"] forState:UIControlStateHighlighted];
        [self setTitle:@"Back" forState:UIControlStateNormal];
        self.titleLabel.font = [UIFont boldSystemFontOfSize:13.0f];
    }
    return self;
}

- (CGRect)titleRectForContentRect:(CGRect)contentRect {
    return CGRectOffset([super titleRectForContentRect:contentRect], 5.0f, 0.0f);
}

- (void)setEnabled:(BOOL)enabled {
    [super setEnabled:enabled];
    
    // Dim the text
    if (enabled == YES) {
        self.titleLabel.alpha = 1.0f;
    } else {
        self.titleLabel.alpha = 0.5f;
    }
}

@end
