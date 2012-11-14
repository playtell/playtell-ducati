//
//  PTCameraButton.m
//  playtell-ducati
//
//  Created by Adam Horne on 11/14/12.
//  Copyright (c) 2012 PlayTell. All rights reserved.
//

#import "PTCameraButton.h"
#import "UIColor+ColorFromHex.h"

@implementation PTCameraButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundImage:[UIImage imageNamed:@"photo-button.png"] forState:UIControlStateNormal];
        [self setBackgroundImage:[UIImage imageNamed:@"photo-button-press.png"] forState:UIControlStateHighlighted];
        
        // Setup the title label
        [self setTitle:@"Retake Photo" forState:UIControlStateNormal];
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
    float xOffset = 0.31 * contentRect.size.width + margin;
    return CGRectMake(xOffset, contentRect.origin.y, contentRect.size.width - (xOffset + margin), contentRect.size.height);
}

@end
