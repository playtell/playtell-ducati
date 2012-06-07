//
//  PTPlaymateButton.m
//  PlayTell
//
//  Created by Ricky Hussmann on 5/25/12.
//  Copyright (c) 2012 PlayTell. All rights reserved.
//

#import "PTPlaymateButton.h"

#import "UIView+PlayTell.h"

#import <QuartzCore/QuartzCore.h>

@interface PTPlaymateButton ()
@property (nonatomic, assign) CGRect originalFrame;
@end

@implementation PTPlaymateButton
@synthesize playmate;
@synthesize originalFrame;

+(PTPlaymateButton*)playmateButtonWithPlaymate:(PTPlaymate*)aPlaymate {
    UIImage* placeholder = [UIImage imageNamed:@"profile_default_2.png"];

    PTPlaymateButton* playmateButton = [PTPlaymateButton buttonWithType:UIButtonTypeCustom];
    [playmateButton setBackgroundImage:placeholder forState:UIControlStateNormal];
    [playmateButton setTitle:aPlaymate.username forState:UIControlStateNormal];
    playmateButton.titleLabel.font = [self playmateNameFont];
    playmateButton.layer.cornerRadius = 10.0;

    CGRect buttonFrame = CGRectZero;
    buttonFrame.size = placeholder.size;
    playmateButton.frame = buttonFrame;

    CGRect buttonLabelFrame = playmateButton.titleLabel.frame;
    buttonLabelFrame.origin.y = CGRectGetHeight(playmateButton.bounds) - buttonLabelFrame.size.height - 2.0;
    playmateButton.titleEdgeInsets = UIEdgeInsetsMake(CGRectGetHeight(playmateButton.bounds) - buttonLabelFrame.size.height - 2.0,
                                                     0,
                                                     0, 0);
    playmateButton.playmate = aPlaymate;

//    CGRect containerFrame = CGRectMake(0, 0, 100, 30);
//    UIView* container = [[UIView alloc] initWithFrame:containerFrame];
//    container.backgroundColor = [UIColor blueColor];
//
//    [playmateButton addSubviewAndCenter:container];
//    containerFrame = container.frame;
//    containerFrame.origin.y = buttonFrame.size.height-1;
//    container.frame = containerFrame;
    return playmateButton;
}

+ (UIFont*)playmateNameFont {
    return [UIFont fontWithName:@"HelveticaNeue-Bold" size:20];
}

- (void)setRequestingPlaydate {
    self.originalFrame = self.frame;
    CGRect expandedFrame = CGRectInset(self.frame, -10, -10);
    self.frame = expandedFrame;
}

- (void)resetButton {
    self.frame = self.originalFrame;
}

@end
