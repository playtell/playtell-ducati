//
//  PTBooksScrollView.m
//  PlayTell
//
//  Created by Dimitry Bentsionov on 5/21/12.
//  Copyright (c) 2012 PlayTell. All rights reserved.
//

#import "PTBooksScrollView.h"
#import "PTBookView.h"

@implementation PTBooksScrollView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setClipsToBounds:NO];
        [self setUserInteractionEnabled:YES];
        [self setCanCancelContentTouches:YES];
        [self setDelaysContentTouches:YES];
        [self setShowsHorizontalScrollIndicator:NO];
        [self setPagingEnabled:YES];
        isBookOpen = NO;
    }
    return self;
}

- (void)hideAllBooksExcept:(NSString *)bookId {
    for (PTBookView *bookView in self.subviews) {
        if (![bookView isKindOfClass:[PTBookView class]] || [[bookView getId] isEqualToString:bookId]) {
            continue;
        }
        [bookView hide];
    }
}

- (void)showAllBooksExcept:(NSString *)bookId {
    for (PTBookView *bookView in self.subviews) {
        if (![bookView isKindOfClass:[PTBookView class]] || [[bookView getId] isEqualToString:bookId]) {
            continue;
        }
        [bookView show];
    }
}

@end