//
//  PTDropDownButton.m
//  playtell-ducati
//
//  Created by Adam Horne on 2/18/13.
//  Copyright (c) 2013 PlayTell. All rights reserved.
//

#import "PTDropDownButton.h"

#import "UIColor+ColorFromHex.h"

@implementation PTDropDownButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundImage:[UIImage imageNamed:@"dropdown-button.png"] forState:UIControlStateNormal];
        [self setBackgroundImage:[UIImage imageNamed:@"dropdwown-press.png"] forState:UIControlStateHighlighted];
        
        // Setup the title label
        [self setTitle:@"Drop Down" forState:UIControlStateNormal];
        [self.titleLabel setTextAlignment:UITextAlignmentCenter];
        [self setTitleColor:[UIColor colorFromHex:@"#223844"] forState:UIControlStateNormal];
        [self setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.titleLabel setFont:[UIFont boldSystemFontOfSize:22.0f]];
        [self.titleLabel setShadowOffset:CGSizeMake(0.0f, 1.0f)];
    }
    return self;
}

//- (CGRect)titleRectForContentRect:(CGRect)contentRect {
//    float margin = 5.0f;
//    float xOffset = 0.25 * contentRect.size.width + margin;
//    return CGRectMake(margin, contentRect.origin.y, contentRect.size.width - (xOffset + margin), contentRect.size.height);
//}

@end
