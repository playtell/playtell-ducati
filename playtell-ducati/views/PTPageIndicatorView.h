//
//  PTPageIndicatorView.h
//  playtell-ducati
//
//  Created by Dimitry Bentsionov on 10/1/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PTPageIndicatorView : UIView {
    NSInteger page;
    UIImageView *currentPageImageView;
}

@property (nonatomic) NSInteger page;

- (id)initWithFrame:(CGRect)frame andPage:(NSInteger)currentPage;
- (void)moveToNewCurrentPage:(NSInteger)newPage;

@end