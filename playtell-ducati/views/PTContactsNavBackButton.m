//
//  PTContactsNavBackButton.m
//  playtell-ducati
//
//  Created by Dimitry Bentsionov on 8/3/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import "PTContactsNavBackButton.h"

@implementation PTContactsNavBackButton

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
        [self setBackgroundImage:[UIImage imageNamed:@"backpress.png"] forState:UIControlStateHighlighted];
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
