//
//  PTContactsTableRemoveCell.h
//  playtell-ducati
//
//  Created by Dimitry Bentsionov on 8/2/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PTContactSelectDelegate.h"

@interface PTContactsTableRemoveCell : UITableViewCell {
    UIImageView *avatar;
    UILabel *lblTitle;
    UILabel *lblDetail;
    UIButton *buttonAction;
    NSMutableDictionary *_contact;
    CGFloat tableWidth;
    id<PTContactSelectDelegate> delegate;
}

@property (nonatomic, retain) UILabel *lblTitle;
@property (nonatomic, retain) UILabel *lblDetail;
@property (nonatomic, retain) NSMutableDictionary *contact;
@property (nonatomic, retain) id<PTContactSelectDelegate> delegate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier tableWidth:(CGFloat)width;

@end