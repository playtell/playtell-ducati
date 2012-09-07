//
//  PTContactsNavCancelButton.m
//  playtell-ducati
//
//  Created by Dimitry Bentsionov on 8/3/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import "PTContactsNavCancelButton.h"

@implementation PTContactsNavCancelButton

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundImage:[UIImage imageNamed:@"buttonUninviteNormal"] forState:UIControlStateNormal];
        [self setBackgroundImage:[UIImage imageNamed:@"buttonUninviteHighlighted"] forState:UIControlStateHighlighted];
        [self setTitle:@"Cancel" forState:UIControlStateNormal];
        self.titleLabel.font = [UIFont boldSystemFontOfSize:13.0f];
    }
    return self;
}

@end
