//
//  PTContactsTableBigCell.m
//  playtell-ducati
//
//  Created by Dimitry Bentsionov on 8/1/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import "PTContactsTableBigCell.h"
#import "UIColor+HexColor.h"
#import <QuartzCore/QuartzCore.h>

@implementation PTContactsTableBigCell

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
        avatar = [[AsyncImageView alloc] initWithFrame:CGRectMake(31.0f, 19.0f, 100.0f, 75.0f)];
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
            [buttonAction setBackgroundImage:[UIImage imageNamed:@"buttonInviteNormal"] forState:UIControlStateNormal];
            [buttonAction setBackgroundImage:[UIImage imageNamed:@"buttonInviteHighlighted"] forState:UIControlStateHighlighted];
            [buttonAction setTitle:@"Invite" forState:UIControlStateNormal];
            [buttonAction setTitleShadowColor:[UIColor colorFromHex:@"#39586d"] forState:UIControlStateNormal];
            buttonAction.titleLabel.font = [UIFont boldSystemFontOfSize:13.0f];
            buttonAction.frame = CGRectMake((tableWidth - 31.0f - 82.0f), 40.0f, 82.0f, 33.0f);
            buttonAction.titleEdgeInsets = UIEdgeInsetsMake(0.0f, 22.0f, 0.0f, 0.0f);
            self.contentView.backgroundColor = [UIColor colorFromHex:@"#f0f7f7"];
            avatar.image = [UIImage imageNamed:@"contactsTableInvited"];
            break;
        }
        case PTContactsTableBigCellModeUninvite: {
            [buttonAction setBackgroundImage:[UIImage imageNamed:@"buttonRemoveNormal"] forState:UIControlStateNormal];
            [buttonAction setBackgroundImage:[UIImage imageNamed:@"buttonRemoveHighlighted"] forState:UIControlStateHighlighted];
            [buttonAction setTitle:@"Cancel" forState:UIControlStateNormal];
            [buttonAction setTitleShadowColor:[UIColor colorFromHex:@"#2d383e"] forState:UIControlStateNormal];
            buttonAction.titleLabel.font = [UIFont boldSystemFontOfSize:13.0f];
            buttonAction.frame = CGRectMake((tableWidth - 31.0f - 94.0f), 40.0f, 94.0f, 33.0f);
            buttonAction.titleEdgeInsets = UIEdgeInsetsMake(0.0f, 28.0f, 0.0f, 0.0f);
            self.contentView.backgroundColor = [UIColor colorFromHex:@"#cde7f7"];
            avatar.image = [UIImage imageNamed:@"contactsTableInvite"];
            break;
        }
        case PTContactsTableBigCellModeFriend: {
            [buttonAction setBackgroundImage:[UIImage imageNamed:@"buttonInviteNormal"] forState:UIControlStateNormal];
            [buttonAction setBackgroundImage:[UIImage imageNamed:@"buttonInviteHighlighted"] forState:UIControlStateHighlighted];
            [buttonAction setTitle:@"Friend" forState:UIControlStateNormal];
            [buttonAction setTitleShadowColor:[UIColor colorFromHex:@"#39586d"] forState:UIControlStateNormal];
            buttonAction.titleLabel.font = [UIFont boldSystemFontOfSize:13.0f];
            buttonAction.frame = CGRectMake((tableWidth - 31.0f - 82.0f), 40.0f, 82.0f, 33.0f);
            buttonAction.titleEdgeInsets = UIEdgeInsetsMake(0.0f, 22.0f, 0.0f, 0.0f);
            self.contentView.backgroundColor = [UIColor colorFromHex:@"#f0f7f7"];
            [avatar setImageURL:[NSURL URLWithString:[self.contact objectForKey:@"profile_photo"]]];
            break;
        }
        case PTContactsTableBigCellModeCancelFriend: {
            [buttonAction setBackgroundImage:[UIImage imageNamed:@"buttonUninviteNormal"] forState:UIControlStateNormal];
            [buttonAction setBackgroundImage:[UIImage imageNamed:@"buttonUninviteHighlighted"] forState:UIControlStateHighlighted];
            [buttonAction setTitle:@"Cancel" forState:UIControlStateNormal];
            [buttonAction setTitleShadowColor:[UIColor colorFromHex:@"#39586d"] forState:UIControlStateNormal];
            buttonAction.titleLabel.font = [UIFont boldSystemFontOfSize:13.0f];
            buttonAction.frame = CGRectMake((tableWidth - 31.0f - 65.0f), 40.0f, 65.0f, 33.0f);
            buttonAction.titleEdgeInsets = UIEdgeInsetsZero;
            self.contentView.backgroundColor = [UIColor colorFromHex:@"#cde7f7"];
            [avatar setImageURL:[NSURL URLWithString:[self.contact objectForKey:@"profile_photo"]]];
            break;
        }
        case PTContactsTableBigCellModeAlreadyFriend: {
            [buttonAction setBackgroundImage:[UIImage imageNamed:@"buttonFriendsNormal"] forState:UIControlStateNormal];
            [buttonAction setBackgroundImage:[UIImage imageNamed:@"buttonFriendsHighlighted"] forState:UIControlStateHighlighted];
            // Are we pending friends or confirmed friends?
            BOOL isConfirmedFriend = [[self.contact objectForKey:@"is_confirmed_friend"] boolValue];
            BOOL isPendingFriend = [[self.contact objectForKey:@"is_pending_friend"] boolValue];
            if (isConfirmedFriend == YES) {
                [buttonAction setTitle:@"Friends" forState:UIControlStateNormal];
            } else if (isPendingFriend == YES) {
                [buttonAction setTitle:@"Pending" forState:UIControlStateNormal];
            }
            [buttonAction setTitleShadowColor:[UIColor colorFromHex:@"#39586d"] forState:UIControlStateNormal];
            buttonAction.titleLabel.font = [UIFont boldSystemFontOfSize:13.0f];
            buttonAction.frame = CGRectMake((tableWidth - 31.0f - 82.0f), 40.0f, 82.0f, 33.0f);
            buttonAction.titleEdgeInsets = UIEdgeInsetsZero;
            [buttonAction setEnabled:NO];
            self.contentView.backgroundColor = [UIColor colorFromHex:@"#cde7f7"];
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
    lblTitle.text = [contact objectForKey:@"name"];
    if ([[contact objectForKey:@"user_id"] isKindOfClass:[NSNull class]]) {
        lblDetail.text = [contact objectForKey:@"email"];
        [buttonAction setEnabled:YES];
    } else {
        BOOL isConfirmedFriend = [[contact objectForKey:@"is_confirmed_friend"] boolValue];
        BOOL isPendingFriend = [[contact objectForKey:@"is_pending_friend"] boolValue];
        if (isConfirmedFriend || isPendingFriend) {
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
