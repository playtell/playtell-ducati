//
//  PTContactsInviteMoreButton.m
//  playtell-ducati
//
//  Created by Dimitry Bentsionov on 9/25/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import "PTContactsInviteMoreButton.h"
#import "UIColor+ColorFromHex.h"

@implementation PTContactsInviteMoreButton

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    [self setBackgroundImage:[UIImage imageNamed:@"invite-more.png"] forState:UIControlStateNormal];
    [self setBackgroundImage:[UIImage imageNamed:@"invite-more-press.png"] forState:UIControlStateHighlighted];
    [self setTitle:@"Invite More" forState:UIControlStateNormal];
    self.titleLabel.font = [UIFont boldSystemFontOfSize:12.0f];
    [self setTitleColor:[UIColor colorFromHex:@"#2d4857"] forState:UIControlStateNormal];
//    self.titleLabel.shadowColor = [UIColor colorFromHex:@"#ffffff"];
//    self.titleLabel.shadowOffset = CGSizeMake(0.0f, -1.0f);
}

- (CGRect)titleRectForContentRect:(CGRect)contentRect {
    return CGRectOffset([super titleRectForContentRect:contentRect], 7.0f, -1.0f);
}

@end