//
//  PTBooksScrollView.h
//  PlayTell
//
//  Created by Dimitry Bentsionov on 5/21/12.
//  Copyright (c) 2012 PlayTell. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PTBooksScrollView : UIScrollView {
    BOOL isBookOpen;
}

- (void)hideAllBooksExcept:(NSNumber *)bookId;
- (void)showAllBooksExcept:(NSNumber *)bookId;
- (void)showAllBooksImmediatelyExcept:(NSNumber *)bookId;
- (void)navigateToBook:(NSNumber *)bookId;

@end
