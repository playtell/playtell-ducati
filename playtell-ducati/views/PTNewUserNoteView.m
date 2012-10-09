//
//  PTNewUserNoteView.m
//  playtell-ducati
//
//  Created by Dimitry Bentsionov on 10/4/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import "PTNewUserNoteView.h"
#import "UIColor+ColorFromHex.h"

@implementation PTNewUserNoteView

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
    // Background
    self.backgroundColor = [UIColor colorFromHex:@"#a2b6b7"];
    
    // Top border
    topBorder = [CALayer layer];
    topBorder.backgroundColor = [UIColor colorFromHex:@"#788888"].CGColor;
    [self.layer addSublayer:topBorder];
    
    // Bottom border
    bottomBorder = [CALayer layer];
    bottomBorder.backgroundColor = [UIColor whiteColor].CGColor;
    [self.layer addSublayer:bottomBorder];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    // Border sizings
    topBorder.frame = CGRectMake(0.0f, 0.0f, self.bounds.size.width, 2.0f);
    bottomBorder.frame = CGRectMake(0.0f, self.bounds.size.height - 1.0f, self.bounds.size.width, 1.0f);
}

@end