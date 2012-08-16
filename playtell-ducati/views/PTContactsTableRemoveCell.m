//
//  PTContactsTableRemoveCell.m
//  playtell-ducati
//
//  Created by Dimitry Bentsionov on 8/2/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import "PTContactsTableRemoveCell.h"
#import "UIColor+HexColor.h"
#import <QuartzCore/QuartzCore.h>

@implementation PTContactsTableRemoveCell

@synthesize lblTitle, lblDetail, delegate;
@synthesize contact = _contact;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier tableWidth:(CGFloat)width {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Table with
        tableWidth = width;

        // Separator top
        CALayer *sep = [CALayer layer];
        sep.backgroundColor = [UIColor whiteColor].CGColor;
        sep.frame = CGRectMake(0.0f, 0.0f, tableWidth, 1.0f);
        [self.layer addSublayer:sep];
        
        // Avatar
        avatar = [[UIImageView alloc] initWithFrame:CGRectMake(31.0f, 19.0f, 100.0f, 75.0f)];
        [self.contentView addSubview:avatar];
        
        // Lbls
        lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(143.0f, 35.0f, tableWidth - 267.0f, 21.0f)];
        lblTitle.backgroundColor = [UIColor clearColor];
        lblTitle.font = [UIFont boldSystemFontOfSize:20.0f];
        lblTitle.textColor = [UIColor colorFromHex:@"#636363"];
        [self.contentView addSubview:lblTitle];
        
        lblDetail = [[UILabel alloc] initWithFrame:CGRectMake(143.0f, 60.0f, tableWidth - 267.0f, 19.0f)];
        lblDetail.backgroundColor = [UIColor clearColor];
        lblDetail.font = [UIFont systemFontOfSize:16.0f];
        lblDetail.textColor = [UIColor colorFromHex:@"#636363"];
        [self.contentView addSubview:lblDetail];
        
        // Action button
        buttonAction = [UIButton buttonWithType:UIButtonTypeCustom];
        [buttonAction setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        buttonAction.titleLabel.shadowOffset = CGSizeMake(0.0f, -1.0f);
        [buttonAction addTarget:self action:@selector(buttonDidPress:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:buttonAction];
        
        // Configure presentation (button, avatar, background)
        [buttonAction setBackgroundImage:[UIImage imageNamed:@"buttonRemoveNormal"] forState:UIControlStateNormal];
        [buttonAction setBackgroundImage:[UIImage imageNamed:@"buttonRemoveHighlighted"] forState:UIControlStateHighlighted];
        [buttonAction setTitle:@"Remove" forState:UIControlStateNormal];
        [buttonAction setTitleShadowColor:[UIColor colorFromHex:@"#39586d"] forState:UIControlStateNormal];
        buttonAction.titleLabel.font = [UIFont boldSystemFontOfSize:13.0f];
        buttonAction.frame = CGRectMake((tableWidth - 31.0f - 94.0f), 40.0f, 94.0f, 33.0f);
        buttonAction.titleEdgeInsets = UIEdgeInsetsMake(0.0f, 28.0f, 0.0f, 0.0f);
        self.contentView.backgroundColor = [UIColor colorFromHex:@"#f0f7f7"];
        avatar.image = [UIImage imageNamed:@"contactsTableInvited"];
    }
    return self;
}

- (void)setContact:(NSMutableDictionary *)contact {
    _contact = contact;
    lblTitle.text = [contact objectForKey:@"name"];
    if ([[contact objectForKey:@"user_id"] isKindOfClass:[NSNull class]]) {
        lblDetail.text = [contact objectForKey:@"email"];
    }
}

- (void)buttonDidPress:(UIButton *)button {
    if ([delegate respondsToSelector:@selector(contactDidCancelInvite:cell:)]) {
        [delegate contactDidCancelInvite:self.contact cell:self];
    }
}

@end