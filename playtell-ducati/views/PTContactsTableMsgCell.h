//
//  PTContactsTableMsgCell.h
//  playtell-ducati
//
//  Created by Dimitry Bentsionov on 8/10/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PTContactsTableBigCell.h"

@interface PTContactsTableMsgCell : UITableViewCell {
    CGFloat tableWidth;
    AsyncImageView *avatar;
    UILabel *lblTitle;
    UILabel *lblTitle2;
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

@end