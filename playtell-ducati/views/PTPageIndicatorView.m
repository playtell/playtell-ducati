//
//  PTPageIndicatorView.m
//  playtell-ducati
//
//  Created by Dimitry Bentsionov on 10/1/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import "PTPageIndicatorView.h"
#import <QuartzCore/QuartzCore.h>

@implementation PTPageIndicatorView

@synthesize page = _page;

- (id)initWithFrame:(CGRect)frame andPage:(NSInteger)currentPage {
    self = [super initWithFrame:frame];
    if (self) {
        self.page = currentPage;
        
        // Draw the 4 blank pages
        CGFloat x = 0.0f;
        for (int i=0; i<4; i++) {
            UIImageView *pageImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"page-indicator"]];
            pageImageView.frame = CGRectMake(x, 0.0f, 21.0f, 21.0f);
            [self addSubview:pageImageView];
            
            // Advance x position
            x += 26.0f;
        }
        
        // Draw the current page
        x = (self.page - 1) * 26.0f;
        currentPageImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"current-page-indicator"]];
        currentPageImageView.frame = CGRectMake(x, 0.0f, 21.0f, 21.0f);
        currentPageImageView.alpha = 0;
        [self addSubview:currentPageImageView];
    }
    return self;
}

- (void)moveToNewCurrentPage:(NSInteger)newPage {
    [currentPageImageView.layer removeAllAnimations];
    [UIView animateWithDuration:0.15f animations:^{
        currentPageImageView.alpha = 0;
    } completion:^(BOOL finished) {
        self.page = newPage;
        currentPageImageView.frame = CGRectMake((self.page - 1) * 26.0f, 0.0f, 21.0f, 21.0f);
        [UIView animateWithDuration:0.15f animations:^{
            currentPageImageView.alpha = 1;
        }];
    }];
}

- (void)showCurrentPageView {
    [currentPageImageView.layer removeAllAnimations];
    currentPageImageView.frame = CGRectMake((self.page - 1) * 26.0f, 0.0f, 21.0f, 21.0f);
    [UIView animateWithDuration:0.1f animations:^{
        currentPageImageView.alpha = 1;
    }];
}

@end