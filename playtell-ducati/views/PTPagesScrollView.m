//
//  PTPagesScrollView.m
//  PlayTell
//
//  Created by Dimitry Bentsionov on 5/22/12.
//  Copyright (c) 2012 PlayTell. All rights reserved.
//

#import "PTPagesScrollView.h"
#import "PTPageView.h"

@implementation PTPagesScrollView

@synthesize pagesScrollDelegate;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setClipsToBounds:NO];
        [self setUserInteractionEnabled:YES];
        [self setCanCancelContentTouches:YES];
        [self setDelaysContentTouches:YES];
        [self setShowsHorizontalScrollIndicator:NO];
        [self setPagingEnabled:YES];
        [self setBounces:YES];
        pageSize = frame.size;
        currentPage = 1;
    }
    return self;
}

- (void)layoutSubviews {
    // Make sure to keep all pages from scrolling (keep them centered)
    CGFloat x = self.contentOffset.x;
    CGFloat page = x / pageSize.width + 1.0f;
    for (PTPageView *pageView in self.subviews) {
        if ([pageView isKindOfClass:[UIImageView class]]) { // Skip the image view that's inside the scroll view by default
            continue;
        }
        pageView.frame = CGRectMake(x, 0.0f, pageSize.width, pageSize.height);
        [pageView setCurrentPage:page andForceOpen:[self isHidden]];
    }

    // Notify delegate of page turn & save book config
    if (page == round(page) && currentPage != round(page)) {
        currentPage = (NSInteger)round(page);
        [book setObject:[NSNumber numberWithInt:currentPage] forKey:@"current_page"];
        [pagesScrollDelegate pageTurnedTo:currentPage];
    }
}

- (void)navigateToPage:(NSInteger)page {
    currentPage = page;

    // Navigate scrollview to right page
    [self setContentOffset:CGPointMake(self.frame.size.width * (currentPage - 1), 0.0f) animated:![self isHidden]];
}

- (void)setCurrentBook:(NSMutableDictionary *)bookData {
    // Check if current book is already the one set
    if (book != nil && [[book objectForKey:@"id"] isEqualToNumber:[bookData objectForKey:@"id"]]) {
        return;
    }

    // Save pointer to book locally
    book = bookData;

    // Get book's current page
    currentPage = [[book objectForKey:@"current_page"] intValue];
    //currentPage = 1; // Currently, always starting from first page

    // Delete all current page views
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];

    // Create new pages
    int totalPages = [[book objectForKey:@"total_pages"] intValue];;
    for (int i=0; i<totalPages; i++) {
        PTPageView *page = [[PTPageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 800.0f, 600.0f) andPageNumber:(i + 1)];
        [self addSubview:page];
    }
    [self setContentSize:CGSizeMake(totalPages * 800.0f, 0.0f)];
    [self setContentOffset:CGPointMake(0.0f, 0.0f)];

    // Navigate to the page saved in the book config
    [self navigateToPage:currentPage];
}

@end
