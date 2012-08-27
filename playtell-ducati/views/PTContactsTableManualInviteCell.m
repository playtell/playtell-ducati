//
//  PTContactsTableManualInviteCell.m
//  playtell-ducati
//
//  Created by Dimitry Bentsionov on 8/20/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import "PTContactsTableManualInviteCell.h"
#import "UIColor+HexColor.h"
#import <QuartzCore/QuartzCore.h>

@implementation PTContactsTableManualInviteCell

@synthesize lblTitle, delegate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier tableWidth:(CGFloat)width {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.backgroundColor = [UIColor clearColor];
        
        // Table with
        tableWidth = width;
        
        // Lbl
        lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(31.0f, 45.0f, tableWidth - 209.0f, 21.0f)];
        lblTitle.backgroundColor = [UIColor clearColor];
        lblTitle.font = [UIFont boldSystemFontOfSize:20.0f];
        lblTitle.textColor = [UIColor colorFromHex:@"#636363"];
        lblTitle.text = @"Didn't find who you're looking for?";
        [self.contentView addSubview:lblTitle];
        
        // Action button
        buttonAction = [UIButton buttonWithType:UIButtonTypeCustom];
        [buttonAction setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        buttonAction.titleLabel.shadowOffset = CGSizeMake(0.0f, -1.0f);
        [buttonAction addTarget:self action:@selector(buttonDidPress:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:buttonAction];
        
        // Configure presentation (button, background)
        [buttonAction setBackgroundImage:[UIImage imageNamed:@"buttonManualInviteNormal"] forState:UIControlStateNormal];
        [buttonAction setBackgroundImage:[UIImage imageNamed:@"buttonManualInviteHighlighted"] forState:UIControlStateHighlighted];
        [buttonAction setTitle:@"Manual Invite" forState:UIControlStateNormal];
        [buttonAction setTitleShadowColor:[UIColor colorFromHex:@"#39586d"] forState:UIControlStateNormal];
        buttonAction.titleLabel.font = [UIFont boldSystemFontOfSize:13.0f];
        buttonAction.frame = CGRectMake((tableWidth - 126.0f - 31.0f), 40.0f, 126.0f, 33.0f);
        buttonAction.titleEdgeInsets = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 20.0f);
        self.backgroundColor = [UIColor colorFromHex:@"#DAE5EA"];
    }
    return self;
}

- (void)buttonDidPress:(UIButton *)button {
    if ([delegate respondsToSelector:@selector(contactDidPressManualInvite:)]) {
        [delegate contactDidPressManualInvite:self];
    }
}

@end