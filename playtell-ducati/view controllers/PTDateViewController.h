//
//  PTDateViewController.h
//  playtell-ducati
//
//  Created by Dimitry Bentsionov on 6/4/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PTPageView.h"
#import "PTBookView.h"
#import "PTBooksScrollView.h"
#import "PTBooksParentView.h"
#import "PTPagesScrollView.h"

@interface PTDateViewController : UIViewController <UIWebViewDelegate, UIScrollViewDelegate, PTBookViewDelegate, PTPagesScrollViewDelegate> {
    // Books
    PTBooksParentView *booksParentView;
    PTBooksScrollView *booksScrollView;
    NSString *currentBookId;
    NSMutableDictionary *books;
    NSMutableArray *bookList;
    BOOL isBookOpen;
    NSMutableArray *coversToLoad;
    NSInteger coversToLoadIndex;
    NSMutableArray *firstPagesToLoad;
    NSInteger firstPagesToLoadIndex;
    
    // Pages
    PTPagesScrollView *pagesScrollView;
    NSMutableArray *pagesToLoad;
    NSInteger pagesToLoadIndex;
    NSInteger currentPage;
    
    // Page loader
    UIWebView *webView;
}

@property (nonatomic, retain) IBOutlet UIButton *resetButton;
- (IBAction)resetPages;

@end
