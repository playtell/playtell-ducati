//
//  PTPagesScrollView.h
//  PlayTell
//
//  Created by Dimitry Bentsionov on 5/22/12.
//  Copyright (c) 2012 PlayTell. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PTPageView.h"
#import "PTPagesScrollViewDelegate.h"

@interface PTPagesScrollView : UIScrollView <UIScrollViewDelegate> {
    NSInteger currentPage;
    CGSize pageSize;
    id<PTPagesScrollViewDelegate> pagesScrollDelegate;
    NSMutableDictionary *book;
    NSMutableArray *pages;
    NSInteger totalPages;
}

@property (nonatomic, retain) id<PTPagesScrollViewDelegate> pagesScrollDelegate;
@property (nonatomic) NSInteger currentPage;
@property (nonatomic) NSInteger totalPages;

- (void)navigateToPage:(NSInteger)page;
- (void)setCurrentBook:(NSMutableDictionary *)bookData;
- (PTPageView *)getPageViewAtPageNumber:(NSInteger)pageNumber;

@end