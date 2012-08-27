//
//  PTContactsTableManualInviteCell.h
//  playtell-ducati
//
//  Created by Dimitry Bentsionov on 8/20/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PTContactSelectDelegate.h"

@interface PTContactsTableManualInviteCell : UITableViewCell {
    CGFloat tableWidth;
    UILabel *lblTitle;
    UIButton *buttonAction;
    id<PTContactSelectDelegate> delegate;
}

@property (nonatomic, retain) UILabel *lblTitle;
@property (nonatomic, retain) id<PTContactSelectDelegate> delegate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier tableWidth:(CGFloat)width;

@end