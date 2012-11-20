//
//  PTBadgeButton.m
//  playtell-ducati
//
//  Created by Adam Horne on 11/20/12.
//  Copyright (c) 2012 PlayTell. All rights reserved.
//

#define SMALL_WIDTH     24.0
#define SMALL_HEIGHT    25.0
#define LARGE_WIDTH     32.0
#define LARGE_HEIGHT    25.0

#import "PTBadgeButton.h"

@interface PTBadgeButton ()

@property (nonatomic, strong) UIImageView *badgeView;
@property (nonatomic, strong) UILabel *badgeLabel;

@end

@implementation PTBadgeButton

@synthesize badgeView;
@synthesize badgeLabel;

NSInteger _badgeNumber;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _badgeNumber = 0;
        
        // Setup the badge image view
        badgeView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"notification-bubble-a.png"]];
        badgeView.frame = CGRectMake(frame.size.width - SMALL_WIDTH, 0.0f, SMALL_WIDTH, SMALL_HEIGHT);
        badgeView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
        badgeView.autoresizesSubviews = YES;
        badgeView.hidden = YES;
        [self addSubview:badgeView];
        
        // Setup the badge number label
        float margin = 4.0f;
        badgeLabel = [[UILabel alloc] initWithFrame:CGRectMake(margin, margin, badgeView.frame.size.width - (2 * margin), badgeView.frame.size.height - (2 * margin + 2.0))];
        badgeLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        badgeLabel.font = [UIFont boldSystemFontOfSize:18.0f];
        badgeLabel.textAlignment = UITextAlignmentCenter;
        badgeLabel.textColor = [UIColor whiteColor];
        badgeLabel.backgroundColor = [UIColor clearColor];
        badgeLabel.adjustsFontSizeToFitWidth = YES;
        badgeLabel.minimumFontSize = 14.0f;
        badgeLabel.text = [NSString stringWithFormat:@"%d", _badgeNumber];
        [badgeView addSubview:badgeLabel];
    }
    return self;
}

- (void)setBadgeNumber:(NSInteger)number {
    _badgeNumber = number;
    if (_badgeNumber < 100) {
        badgeLabel.text = [NSString stringWithFormat:@"%d", _badgeNumber];
    } else {
        badgeLabel.text = @"99+";
    }
    
    if (_badgeNumber == 0) {
        badgeView.hidden = YES;
    } else if (_badgeNumber < 10) {
        // Set the small badge image
        badgeView.image = [UIImage imageNamed:@"notification-bubble-a.png"];
        badgeView.frame = CGRectMake(self.frame.size.width - SMALL_WIDTH, 0.0f, SMALL_WIDTH, SMALL_HEIGHT);
        
        badgeView.hidden = NO;
    } else {
        // Set the large badge image
        badgeView.image = [UIImage imageNamed:@"notification-bubble-b.png"];
        badgeView.frame = CGRectMake(self.frame.size.width - LARGE_WIDTH, 0.0f, LARGE_WIDTH, LARGE_HEIGHT);
        
        badgeView.hidden = NO;
    }
}

- (NSInteger)badgeNumber {
    return _badgeNumber;
}

@end
