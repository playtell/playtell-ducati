//
//  PTErrorTableCell.m
//  playtell-ducati
//
//  Created by Dimitry Bentsionov on 10/1/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import "PTErrorTableCell.h"

@implementation PTErrorTableCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        UIImageView *errorImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"text-error"]];
        errorImageView.frame = CGRectMake(4.0f, 4.0f, 16.0f, 16.0f);
        UIView *cellBackgroundView = [UIView new];
        [cellBackgroundView addSubview:errorImageView];
        self.backgroundView = cellBackgroundView;
        
        self.textLabel.font = [UIFont systemFontOfSize:13.0f];
        self.textLabel.textColor = [UIColor redColor];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat width = CGRectGetWidth(self.textLabel.frame);
    CGFloat height = CGRectGetHeight(self.textLabel.frame);
    self.textLabel.frame = CGRectMake(27.0f, 0.0f, width - 27.0f, height);
}

@end