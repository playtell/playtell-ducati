//
//  PTPagesScrollView.h
//  PlayTell
//
//  Created by Dimitry Bentsionov on 5/22/12.
//  Copyright (c) 2012 PlayTell. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PTPagesScrollViewDelegate;

@interface PTPagesScrollView : UIScrollView {
    NSInteger currentPage;
    CGSize pageSize;
    id<PTPagesScrollViewDelegate> pagesScrollDelegate;
    NSMutableDictionary *book;
}

@property (nonatomic, retain) id<PTPagesScrollViewDelegate> pagesScrollDelegate;

- (void)navigateToPage:(NSInteger)page;
- (void)setCurrentBook:(NSMutableDictionary *)bookData;

@end

// Delegate definition
@protocol PTPagesScrollViewDelegate
@optional
- (void)pageTurnedTo:(NSInteger)number;
@end