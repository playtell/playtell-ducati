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

@interface PTDateViewController : UIViewController <UIScrollViewDelegate, PTBookViewDelegate, PTPagesScrollViewDelegate> {
    // Playdate
    PTPlaydate *playdate;
    IBOutlet UIButton *endPlaydate;
    IBOutlet UIButton *closeBook;
    IBOutlet UIButton *endPlaydateForreal;
    IBOutlet UIView *endPlaydatePopup;
    
    // Books
    PTBooksParentView *booksParentView;
    PTBooksScrollView *booksScrollView;
    NSNumber *currentBookId;
    NSMutableDictionary *books;
    NSMutableArray *bookList;
    BOOL isBookOpen;
    NSMutableArray *coversToLoad;
    NSInteger coversToLoadIndex;
    BOOL boolListLoadedFromPlist;
    
    // Pages
    PTPagesScrollView *pagesScrollView;
    NSMutableArray *pagesToLoad;
    NSInteger currentPage;
    
    // Page loader
//    UIWebView *webView;
    //BOOL isWebViewLoading;
    BOOL isPageViewLoading;
    
    // Fingers
    NSMutableDictionary *fingerViews;
}

@property (nonatomic) PTPlaydate *playdate;
@property (nonatomic, retain) IBOutlet UIButton *endPlaydate;
@property (nonatomic, retain) IBOutlet UIButton *endPlaydateForreal;
@property (nonatomic, retain) IBOutlet UIButton *closeBook;
@property (nonatomic, retain) IBOutlet UIButton *button2;

@property (nonatomic, retain) IBOutlet UIView *endPlaydatePopup;
- (IBAction)playdateDisconnect:(id)sender;
- (IBAction)playTictactoe:(id)sender;

- (IBAction)endPlaydatePopupToggle:(id)sender;
- (void)openBookAfterNavigation;

@end
