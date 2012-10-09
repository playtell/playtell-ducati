//
//  PTContactsTableBigCell.h
//  playtell-ducati
//
//  Created by Dimitry Bentsionov on 8/1/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PTContactSelectDelegate.h"
#import "AsyncImageView.h"

typedef enum {
    PTContactsTableBigCellModeInvite,
    PTContactsTableBigCellModeUninvite,
    PTContactsTableBigCellModeFriend,
    PTContactsTableBigCellModeCancelFriend,
    PTContactsTableBigCellModeAlreadyFriend
} PTContactsTableBigCellMode;

typedef enum {
    PTContactsTableBigCellActionInvited,
    PTContactsTableBigCellActionUninvited,
    PTContactsTableBigCellActionFriended,
    PTContactsTableBigCellActionCancelledFriending
} PTContactsTableBigCellAction;

@interface PTContactsTableBigCell : UITableViewCell {
    CGFloat tableWidth;
    AsyncImageView *avatar;
    UILabel *lblTitle;
    UILabel *lblDetail;
    UIButton *buttonAction;
    NSMutableDictionary *_contact;
    PTContactsTableBigCellMode _mode;
    id<PTContactSelectDelegate> delegate;
}

@property (nonatomic, retain) UILabel *lblTitle;
@property (nonatomic, retain) UILabel *lblDetail;
@property (nonatomic, retain) NSMutableDictionary *contact;
@property (nonatomic, retain) id<PTContactSelectDelegate> delegate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier tableWidth:(CGFloat)width;
- (void)setMode:(PTContactsTableBigCellMode)mode;
- (PTContactsTableBigCellMode)getMode;

@end
