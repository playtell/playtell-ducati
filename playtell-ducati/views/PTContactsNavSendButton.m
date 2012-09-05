//
//  PTContactsNavSendButton.m
//  playtell-ducati
//
//  Created by Dimitry Bentsionov on 8/9/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import "PTContactsNavSendButton.h"

@implementation PTContactsNavSendButton

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundImage:[UIImage imageNamed:@"buttonSendNormal"] forState:UIControlStateNormal];
        //[self setBackgroundImage:[UIImage imageNamed:@"buttonSendHighlighted"] forState:UIControlStateHighlighted];
        [self setTitle:@"Send" forState:UIControlStateNormal];
        self.titleLabel.font = [UIFont boldSystemFontOfSize:13.0f];
    }
    return self;
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
