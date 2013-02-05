//
//  PTSettingsTitleView.m
//  playtell-ducati
//
//  Created by Adam Horne on 2/4/13.
//  Copyright (c) 2013 PlayTell. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "PTSettingsTitleView.h"

#import "UIColor+ColorFromHex.h"

@interface PTSettingsTitleView ()

@property (nonatomic, strong) CAGradientLayer *gradient;

@end

@implementation PTSettingsTitleView
@synthesize textLabel;

@synthesize gradient;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Setup the background gradient
        gradient = [CAGradientLayer layer];
        gradient.frame = self.bounds;
        gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor colorFromHex:@"D1DAE0"] CGColor], (id)[[UIColor colorFromHex:@"B2C2CC"] CGColor], nil];
        [self.layer insertSublayer:gradient atIndex:0];
        
        // Setup the shadow at the bottom
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shadowOpacity = 0.5f;
        self.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
        self.layer.shadowRadius = 0.0f;
        
        // Setup the text label
        textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.frame.size.width, self.frame.size.height)];
        textLabel.backgroundColor = [UIColor clearColor];
        textLabel.textColor = [UIColor colorFromHex:@"#2E4957"];
        textLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        textLabel.text = @"Title View";
        textLabel.textAlignment = UITextAlignmentCenter;
        textLabel.font = [UIFont systemFontOfSize:frame.size.height - 10];
        textLabel.shadowColor = [UIColor whiteColor];
        textLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
        [self addSubview:textLabel];
    }
    return self;
}

- (void)layoutSubviews {
    gradient.frame = self.bounds;
    textLabel.font = [UIFont systemFontOfSize:self.bounds.size.height - 10];
}

@end
