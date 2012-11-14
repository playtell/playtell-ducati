//
//  PTSendButton.m
//  playtell-ducati
//
//  Created by Adam Horne on 11/14/12.
//  Copyright (c) 2012 PlayTell. All rights reserved.
//

#import "PTSendButton.h"
#import "UIColor+ColorFromHex.h"

@implementation PTSendButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundImage:[UIImage imageNamed:@"email-button.png"] forState:UIControlStateNormal];
        [self setBackgroundImage:[UIImage imageNamed:@"email-button-press.png"] forState:UIControlStateHighlighted];
        
        // Setup the title label
        [self setTitle:@"Send Postcard" forState:UIControlStateNormal];
        [self.titleLabel setTextAlignment:UITextAlignmentLeft];
        [self setTitleColor:[UIColor colorFromHex:@"#223844"] forState:UIControlStateNormal];
        [self setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.titleLabel setFont:[UIFont boldSystemFontOfSize:22.0f]];
        [self.titleLabel setShadowOffset:CGSizeMake(0.0f, 1.0f)];
    }
    return self;
}

- (CGRect)titleRectForContentRect:(CGRect)contentRect {
    float margin = 5.0f;
    float xOffset = 0.25 * contentRect.size.width + margin;
    return CGRectMake(xOffset, contentRect.origin.y, contentRect.size.width - (xOffset + margin), contentRect.size.height);
}

@end
