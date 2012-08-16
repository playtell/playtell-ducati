//
//  PTContactsTableMsgCell.m
//  playtell-ducati
//
//  Created by Dimitry Bentsionov on 8/10/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import "PTContactsTableMsgCell.h"
#import "UIColor+HexColor.h"
#import <QuartzCore/QuartzCore.h>

@implementation PTContactsTableMsgCell

@synthesize lblTitle, lblDetail, delegate;
@synthesize contact = _contact;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier tableWidth:(CGFloat)width {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.backgroundColor = [UIColor clearColor];
        
        // Table with
        tableWidth = width;
        
        // Avatar
        avatar = [[AsyncImageView alloc] initWithFrame:CGRectMake(0.0f, 19.0f, 100.0f, 75.0f)];
        [self.contentView addSubview:avatar];
        
        // Lbls
        lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(112.0f, 25.0f, tableWidth - 209.0f, 21.0f)];
        lblTitle.backgroundColor = [UIColor clearColor];
        lblTitle.font = [UIFont boldSystemFontOfSize:20.0f];
        lblTitle.textColor = [UIColor colorFromHex:@"#636363"];
        [self.contentView addSubview:lblTitle];
        
        lblTitle2 = [[UILabel alloc] initWithFrame:CGRectMake(112.0f, 48.0f, tableWidth - 209.0f, 21.0f)];
        lblTitle2.backgroundColor = [UIColor clearColor];
        lblTitle2.font = [UIFont boldSystemFontOfSize:20.0f];
        lblTitle2.textColor = [UIColor colorFromHex:@"#636363"];
        [self.contentView addSubview:lblTitle2];
        
        lblDetail = [[UILabel alloc] initWithFrame:CGRectMake(112.0f, 71.0f, tableWidth - 209.0f, 19.0f)];
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
        buttonAction.frame = CGRectMake((tableWidth - 94.0f), 40.0f, 94.0f, 33.0f);
        buttonAction.titleEdgeInsets = UIEdgeInsetsMake(0.0f, 28.0f, 0.0f, 0.0f);
        avatar.image = [UIImage imageNamed:@"contactsTableInvited"];
    }
    return self;
}

- (void)setContact:(NSMutableDictionary *)contact {
    _contact = contact;
    NSString *name = [contact objectForKey:@"name"];
    
    NSRange spaceLoc = [name rangeOfString:@" "];
    if (spaceLoc.location == NSNotFound) {
        lblTitle.text = name;
        lblTitle2.text = @"";
    } else {
        lblTitle.text = [name substringToIndex:spaceLoc.location];
        lblTitle2.text = [name substringFromIndex:(spaceLoc.location + spaceLoc.length)];
    }
    
    if ([[contact objectForKey:@"user_id"] isKindOfClass:[NSNull class]]) {
        lblDetail.text = [contact objectForKey:@"email"];
        [buttonAction setEnabled:YES];
    }
}

- (void)buttonDidPress:(UIButton *)button {
    if ([delegate respondsToSelector:@selector(contactDidCancelInvite:cell:)]) {
        [delegate contactDidCancelInvite:self.contact cell:self];
    }
}

@end