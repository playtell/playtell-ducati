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
#import "PTPlaydate.h"

@interface PTDateViewController : UIViewController <UIWebViewDelegate, UIScrollViewDelegate, PTBookViewDelegate, PTPagesScrollViewDelegate> {
    // Playdate
    PTPlaydate *playdate;
    
    // Books
    PTBooksParentView *booksParentView;
    PTBooksScrollView *booksScrollView;
    NSNumber *currentBookId;
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
    BOOL isWebViewLoading;
}

@property (nonatomic) PTPlaydate *playdate;
@property (nonatomic, retain) IBOutlet UIButton *closeBookButton;
- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle andBookList:(NSArray *)allBooks;
- (IBAction)closeBook:(id)sender;
- (IBAction)playdateDisconnect:(id)sender;
- (void)openBookAfterNavigation;

@end
