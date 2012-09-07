//
//  PTContactsTableSmallCell.m
//  playtell-ducati
//
//  Created by Dimitry Bentsionov on 8/2/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import "PTContactsTableSmallCell.h"
#import "UIColor+HexColor.h"
#import <QuartzCore/QuartzCore.h>

@implementation PTContactsTableSmallCell

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
        lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(112.0f, 25.0f, tableWidth - 205.0f, 21.0f)];
        lblTitle.backgroundColor = [UIColor clearColor];
        lblTitle.font = [UIFont boldSystemFontOfSize:20.0f];
        lblTitle.textColor = [UIColor colorFromHex:@"#636363"];
        [self.contentView addSubview:lblTitle];

        lblTitle2 = [[UILabel alloc] initWithFrame:CGRectMake(112.0f, 48.0f, tableWidth - 205.0f, 21.0f)];
        lblTitle2.backgroundColor = [UIColor clearColor];
        lblTitle2.font = [UIFont boldSystemFontOfSize:20.0f];
        lblTitle2.textColor = [UIColor colorFromHex:@"#636363"];
        [self.contentView addSubview:lblTitle2];

        
        lblDetail = [[UILabel alloc] initWithFrame:CGRectMake(112.0f, 71.0f, tableWidth - 205.0f, 19.0f)];
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
        
        // Listen for events
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(actionPerformedOnContact:)
                                                     name:@"actionPerformedOnContact"
                                                   object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setMode:(PTContactsTableBigCellMode)mode {
    _mode = mode;
    switch (mode) {
        case PTContactsTableBigCellModeInvite: {
            break;
        }
        case PTContactsTableBigCellModeUninvite: {
            break;
        }
        case PTContactsTableBigCellModeFriend: {
            [buttonAction setBackgroundImage:[UIImage imageNamed:@"buttonInviteNormal"] forState:UIControlStateNormal];
            [buttonAction setBackgroundImage:[UIImage imageNamed:@"buttonInviteHighlighted"] forState:UIControlStateHighlighted];
            [buttonAction setTitle:@"Friend" forState:UIControlStateNormal];
            [buttonAction setTitleShadowColor:[UIColor colorFromHex:@"#39586d"] forState:UIControlStateNormal];
            buttonAction.titleLabel.font = [UIFont boldSystemFontOfSize:13.0f];
            buttonAction.frame = CGRectMake((tableWidth - 82.0f), 40.0f, 82.0f, 33.0f);
            buttonAction.titleEdgeInsets = UIEdgeInsetsMake(0.0f, 22.0f, 0.0f, 0.0f);
            [avatar setImageURL:[NSURL URLWithString:[self.contact objectForKey:@"profile_photo"]]];
            break;
        }
        case PTContactsTableBigCellModeCancelFriend: {
            [buttonAction setBackgroundImage:[UIImage imageNamed:@"buttonUninviteNormal"] forState:UIControlStateNormal];
            [buttonAction setBackgroundImage:[UIImage imageNamed:@"buttonUninviteHighlighted"] forState:UIControlStateHighlighted];
            [buttonAction setTitle:@"Cancel" forState:UIControlStateNormal];
            [buttonAction setTitleShadowColor:[UIColor colorFromHex:@"#39586d"] forState:UIControlStateNormal];
            buttonAction.titleLabel.font = [UIFont boldSystemFontOfSize:13.0f];
            buttonAction.frame = CGRectMake((tableWidth - 65.0f), 40.0f, 65.0f, 33.0f);
            buttonAction.titleEdgeInsets = UIEdgeInsetsZero;
            [avatar setImageURL:[NSURL URLWithString:[self.contact objectForKey:@"profile_photo"]]];
            break;
        }
        case PTContactsTableBigCellModeAlreadyFriend: {
            [buttonAction setBackgroundImage:[UIImage imageNamed:@"buttonInviteNormal"] forState:UIControlStateNormal];
            [buttonAction setBackgroundImage:[UIImage imageNamed:@"buttonInviteHighlighted"] forState:UIControlStateHighlighted];
            [buttonAction setTitle:@"Friend" forState:UIControlStateNormal];
            [buttonAction setTitleShadowColor:[UIColor colorFromHex:@"#39586d"] forState:UIControlStateNormal];
            buttonAction.titleLabel.font = [UIFont boldSystemFontOfSize:13.0f];
            buttonAction.frame = CGRectMake((tableWidth - 82.0f), 40.0f, 82.0f, 33.0f);
            buttonAction.titleEdgeInsets = UIEdgeInsetsMake(0.0f, 22.0f, 0.0f, 0.0f);
            [buttonAction setEnabled:NO];
            [avatar setImageURL:[NSURL URLWithString:[self.contact objectForKey:@"profile_photo"]]];
            break;
        }
    }
}

- (PTContactsTableBigCellMode)getMode {
    return _mode;
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
    } else {
        BOOL isFriend = [[contact objectForKey:@"is_friend"] boolValue];
        //lblDetail.text = [NSString stringWithFormat:@"Existing user! (%i)", [[contact objectForKey:@"user_id"] integerValue]];
        if (isFriend) {
            [buttonAction setEnabled:NO];
        } else {
            [buttonAction setEnabled:YES];
        }
    }
}

- (void)buttonDidPress:(UIButton *)button {
    switch (_mode) {
        case PTContactsTableBigCellModeInvite: {
            if ([delegate respondsToSelector:@selector(contactDidInvite:cell:)]) {
                [delegate contactDidInvite:self.contact cell:self];
            }
            break;
        }
        case PTContactsTableBigCellModeUninvite: {
            if ([delegate respondsToSelector:@selector(contactDidCancelInvite:cell:)]) {
                [delegate contactDidCancelInvite:self.contact cell:self];
            }
            break;
        }
        case PTContactsTableBigCellModeFriend: {
            if ([delegate respondsToSelector:@selector(contactDidAddFriend:cell:)]) {
                [delegate contactDidAddFriend:self.contact cell:self];
            }
            break;
        }
        case PTContactsTableBigCellModeCancelFriend: {
            break;
        }
        case PTContactsTableBigCellModeAlreadyFriend: {
            break;
        }
    }
}

- (void)actionPerformedOnContact:(NSNotification *)notification {
    NSMutableDictionary *contact = [[notification userInfo] objectForKey:@"contact"];
    if (![[self.contact objectForKey:@"uid"] isEqualToString:[contact objectForKey:@"uid"]]) {
        return;
    }
    
    PTContactsTableBigCellAction action = [[[notification userInfo] objectForKey:@"action"] intValue];
    switch (action) {
        case (PTContactsTableBigCellActionInvited): {
            [self setMode:PTContactsTableBigCellModeUninvite];
            break;
        }
        case (PTContactsTableBigCellActionUninvited): {
            [self setMode:PTContactsTableBigCellModeInvite];
            break;
        }
        case (PTContactsTableBigCellActionFriended): {
            [self setMode:PTContactsTableBigCellModeAlreadyFriend];
            break;
        }
        case (PTContactsTableBigCellActionCancelledFriending): {
            break;
        }
    }
}

@end