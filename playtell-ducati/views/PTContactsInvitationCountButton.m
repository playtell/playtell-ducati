//
//  PTContactsInvitationCountButton.m
//  playtell-ducati
//
//  Created by Dimitry Bentsionov on 7/31/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import "PTContactsInvitationCountButton.h"
#import <QuartzCore/QuartzCore.h>

@implementation PTContactsInvitationCountButton

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Images
        //[self setImage:[UIImage imageNamed:@"buttonInvitationCountEnvNormal"] forState:UIControlStateNormal];
        [self setBackgroundImage:[UIImage imageNamed:@"buttonInvitationCountNormal"] forState:UIControlStateNormal];
        [self setBackgroundImage:[UIImage imageNamed:@"buttonInvitationCountHighlighted"] forState:UIControlStateHighlighted];
        self.adjustsImageWhenHighlighted = NO;
        
        // Font
        self.titleLabel.font = [UIFont boldSystemFontOfSize:23.0f];
        [self setTitleColor:[UIColor colorWithRed:(50.0f / 255.0f) green:(137.0f / 255.0f) blue:(191.0f / 255.0f) alpha:1.0f] forState:UIControlStateNormal];
        [self setTitleColor:[UIColor colorWithRed:(34.0f / 255.0f) green:(100.0f / 255.0f) blue:(121.0f / 255.0f) alpha:1.0f] forState:UIControlStateHighlighted];
        [self setTitleShadowColor:[UIColor colorWithRed:(144.0f / 255.0f) green:(201.0f / 255.0f) blue:(244.0f / 255.0f) alpha:1.0f] forState:UIControlStateNormal];
        self.titleLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
        
        imageCover = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"buttonInvitationCountEnvNormal"]];
        imageCover.frame = self.bounds;
        [self insertSubview:imageCover belowSubview:self.titleLabel];
    }
    return self;
}

- (CGRect)titleRectForContentRect:(CGRect)contentRect {
    return CGRectOffset([super titleRectForContentRect:contentRect], -22.0f, 0.0f);
}

- (CGRect)imageRectForContentRect:(CGRect)contentRect {
    CGRect rect = [super imageRectForContentRect:contentRect];
    imageCover.frame = rect;
    return rect;
}

- (void)setHighlighted:(BOOL)highlighted {
    if (highlighted) {
        self.titleLabel.shadowOffset = CGSizeMake(0.0f, -1.0f);
    } else {
        self.titleLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
    }
    [super setHighlighted:highlighted];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
