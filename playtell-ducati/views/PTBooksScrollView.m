//
//  PTBooksScrollView.m
//  PlayTell
//
//  Created by Dimitry Bentsionov on 5/21/12.
//  Copyright (c) 2012 PlayTell. All rights reserved.
//

#import "PTBooksScrollView.h"
#import "PTBookView.h"
#import "PTGameView.h"

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

- (void)hideAllBooksExcept:(NSNumber *)bookId {
    for (PTBookView *bookView in self.subviews) {
        if (![bookView isKindOfClass:[PTBookView class]] || [[bookView getId] isEqualToNumber:bookId]) {
            continue;
        }
        [bookView hide];
    }
}

- (void)showAllBooksExcept:(NSNumber *)bookId {
    for (PTBookView *bookView in self.subviews) {
        if (![bookView isKindOfClass:[PTBookView class]] || [[bookView getId] isEqualToNumber:bookId]) {
            continue;
        }
        [bookView show];
    }
}

- (void)showAllBooksImmediatelyExcept:(NSNumber *)bookId {
    for (PTBookView *bookView in self.subviews) {
        if (![bookView isKindOfClass:[PTBookView class]] || [[bookView getId] isEqualToNumber:bookId]) {
            continue;
        }
        [bookView showImmediately];
    }
}

- (void)navigateToBook:(NSNumber *)bookId {
    // Go through all the books and find the one we need
    int index = 0;
    for (PTBookView *bookView in self.subviews) {
//        if (![bookView isKindOfClass:[PTBookView class]]) {
//            continue;
//        }
        if (![bookView isKindOfClass:[PTGameView class]] && [[bookView getId] isEqualToNumber:bookId]) {
            break;
        }
        index++;
    }
    
    [self setContentOffset:CGPointMake(self.frame.size.width * index, 0.0f) animated:YES];
}

@end